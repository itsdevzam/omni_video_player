import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Widget wrapper generico per overlay legati a un pulsante
class OverlayButtonWrapper extends StatefulWidget {
  const OverlayButtonWrapper({
    super.key,
    required this.childBuilder,
    required this.overlayBuilder,
    required this.onStartInteraction,
    required this.onEndInteraction,
    this.targetAnchor = Alignment.topCenter,
    this.followerAnchor = Alignment.bottomCenter,
    this.followerOffset = Offset.zero,
    this.screenHorizontalMargin = 12,
    this.useFullWidthMenu = false,
  });

  /// Builder del pulsante: riceve toggleOverlay
  final Widget Function(VoidCallback toggleOverlay, bool expanded) childBuilder;

  /// Builder dell'overlay, riceve una funzione dismiss per chiuderlo
  final Widget Function(VoidCallback dismissOverlay) overlayBuilder;

  final Alignment targetAnchor;

  final Alignment followerAnchor;

  final Offset followerOffset;

  final double screenHorizontalMargin;

  /// When true, menu spans screen width with [screenHorizontalMargin] on both sides.
  final bool useFullWidthMenu;

  final VoidCallback onStartInteraction;
  final VoidCallback onEndInteraction;

  @override
  State<OverlayButtonWrapper> createState() => _OverlayButtonWrapperState();
}

class _OverlayMenuLayout {
  final double? left;
  final double? right;
  final double? top;

  const _OverlayMenuLayout({this.left, this.right, this.top});
}

class _OverlayButtonWrapperState extends State<OverlayButtonWrapper> {
  final GlobalKey _targetKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  _OverlayMenuLayout? _menuLayout;

  void _dismissOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _menuLayout = null;
    widget.onEndInteraction();
    setState(() {});
  }

  double _alignmentToUnit(double alignmentComponent) {
    return (alignmentComponent + 1) / 2;
  }

  _OverlayMenuLayout? _resolveMenuLayout(BuildContext overlayContext) {
    final targetContext = _targetKey.currentContext;
    if (targetContext == null) return null;

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    if (targetBox == null) return null;

    final overlayBox = overlayContext.findRenderObject() as RenderBox?;
    if (overlayBox == null) return null;

    final targetTopLeft = targetBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final targetSize = targetBox.size;
    final margin = widget.screenHorizontalMargin;
    final safePadding = MediaQuery.paddingOf(overlayContext);

    final anchorY =
        targetTopLeft.dy +
        targetSize.height * _alignmentToUnit(widget.targetAnchor.y);
    final top = anchorY + widget.followerOffset.dy;

    if (widget.useFullWidthMenu) {
      return _OverlayMenuLayout(
        left: margin + safePadding.left,
        right: margin + safePadding.right,
        top: top,
      );
    }

    return _OverlayMenuLayout(left: margin + safePadding.left, top: top);
  }

  void _scheduleMenuLayoutUpdate(BuildContext overlayContext) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _overlayEntry == null) return;

      final nextLayout = _resolveMenuLayout(overlayContext);
      if (nextLayout == null) {
        _scheduleMenuLayoutUpdate(overlayContext);
        return;
      }

      if (_menuLayout?.left != nextLayout.left ||
          _menuLayout?.right != nextLayout.right ||
          _menuLayout?.top != nextLayout.top) {
        _menuLayout = nextLayout;
        _overlayEntry?.markNeedsBuild();
        setState(() {});
      }
    });
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _dismissOverlay();
      return;
    }

    _menuLayout = null;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        _menuLayout ??= _resolveMenuLayout(overlayContext);
        _scheduleMenuLayoutUpdate(overlayContext);

        final menu = Material(
          color: Colors.transparent,
          child: widget.overlayBuilder(_dismissOverlay),
        );

        final layout = _menuLayout;
        if (layout == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _dismissOverlay,
                ),
              ),
            ),
            if (widget.useFullWidthMenu)
              Positioned(
                left: layout.left,
                right: layout.right,
                top: layout.top,
                child: menu,
              )
            else
              Positioned(
                left: layout.left,
                top: layout.top,
                child: menu,
              ),
          ],
        );
      },
    );

    widget.onStartInteraction();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {});
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _targetKey,
      child: widget.childBuilder(_toggleOverlay, _overlayEntry != null),
    );
  }
}
