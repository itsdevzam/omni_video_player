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
  });

  /// Builder del pulsante: riceve toggleOverlay
  final Widget Function(VoidCallback toggleOverlay, bool expanded) childBuilder;

  /// Builder dell'overlay, riceve una funzione dismiss per chiuderlo
  final Widget Function(VoidCallback dismissOverlay) overlayBuilder;

  final Alignment targetAnchor;

  final Alignment followerAnchor;

  final Offset followerOffset;

  final double screenHorizontalMargin;

  final VoidCallback onStartInteraction;
  final VoidCallback onEndInteraction;

  @override
  State<OverlayButtonWrapper> createState() => _OverlayButtonWrapperState();
}

class _OverlayButtonWrapperState extends State<OverlayButtonWrapper> {
  final GlobalKey _targetKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Offset _menuPosition = Offset.zero;
  bool _menuPositionReady = false;

  void _dismissOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _menuPositionReady = false;
    widget.onEndInteraction();
    setState(() {});
  }

  double _alignmentToUnit(double alignmentComponent) {
    return (alignmentComponent + 1) / 2;
  }

  void _updateMenuPosition() {
    if (!mounted || _overlayEntry == null) return;

    final targetContext = _targetKey.currentContext;
    final menuContext = _menuKey.currentContext;
    if (targetContext == null || menuContext == null) return;

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final menuBox = menuContext.findRenderObject() as RenderBox?;
    if (targetBox == null || menuBox == null || !menuBox.hasSize) return;

    final overlayBox =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()
            as RenderBox?;
    if (overlayBox == null) return;

    final targetTopLeft = targetBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final targetSize = targetBox.size;
    final menuSize = menuBox.size;
    final screenWidth = overlayBox.size.width;
    final margin = widget.screenHorizontalMargin;

    final anchorX =
        targetTopLeft.dx +
        targetSize.width * _alignmentToUnit(widget.targetAnchor.x);
    final anchorY =
        targetTopLeft.dy +
        targetSize.height * _alignmentToUnit(widget.targetAnchor.y);

    final menuAnchorX =
        menuSize.width * _alignmentToUnit(widget.followerAnchor.x);
    final menuAnchorY =
        menuSize.height * _alignmentToUnit(widget.followerAnchor.y);

    var left = anchorX - menuAnchorX + widget.followerOffset.dx;
    final top = anchorY - menuAnchorY + widget.followerOffset.dy;

    final maxLeft = screenWidth - menuSize.width - margin;
    if (maxLeft < margin) {
      left = margin;
    } else {
      left = left.clamp(margin, maxLeft);
    }

    final nextPosition = Offset(left, top);
    final changed =
        !_menuPositionReady || (_menuPosition - nextPosition).distance > 0.5;

    if (changed) {
      _menuPosition = nextPosition;
      _menuPositionReady = true;
      _overlayEntry?.markNeedsBuild();
      setState(() {});
    }
  }

  void _scheduleMenuPositionUpdate() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateMenuPosition();
      if (!_menuPositionReady) {
        _scheduleMenuPositionUpdate();
      }
    });
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _dismissOverlay();
      return;
    }

    _menuPosition = Offset.zero;
    _menuPositionReady = false;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        _scheduleMenuPositionUpdate();

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
            Positioned(
              left: _menuPosition.dx,
              top: _menuPosition.dy,
              child: Opacity(
                opacity: _menuPositionReady ? 1 : 0,
                child: Material(
                  color: Colors.transparent,
                  child: KeyedSubtree(
                    key: _menuKey,
                    child: widget.overlayBuilder(_dismissOverlay),
                  ),
                ),
              ),
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
