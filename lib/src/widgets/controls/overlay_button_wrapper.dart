import 'package:flutter/material.dart';

/// Widget wrapper generico per overlay legati a un pulsante
class OverlayButtonWrapper extends StatefulWidget {
  const OverlayButtonWrapper({
    super.key,
    required this.childBuilder,
    required this.overlayBuilder,
    required this.onStartInteraction,
    required this.onEndInteraction,
    this.openMenuAbove = false,
    this.followerOffset = Offset.zero,
  });

  /// Builder del pulsante: riceve toggleOverlay
  final Widget Function(VoidCallback toggleOverlay, bool expanded) childBuilder;

  /// Builder dell'overlay, riceve una funzione dismiss per chiuderlo
  final Widget Function(VoidCallback dismissOverlay) overlayBuilder;

  /// Opens the menu above the button when true, below when false.
  final bool openMenuAbove;

  final Offset followerOffset;

  final VoidCallback onStartInteraction;
  final VoidCallback onEndInteraction;

  @override
  State<OverlayButtonWrapper> createState() => _OverlayButtonWrapperState();
}

class _OverlayButtonWrapperState extends State<OverlayButtonWrapper> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _dismissOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    widget.onEndInteraction();
    setState(() {});
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _dismissOverlay();
      return;
    }

    final targetAnchor = widget.openMenuAbove
        ? Alignment.topCenter
        : Alignment.bottomCenter;
    final followerAnchor = widget.openMenuAbove
        ? Alignment.bottomCenter
        : Alignment.topCenter;
    final offset = widget.openMenuAbove
        ? Offset(0, -widget.followerOffset.dy.abs())
        : widget.followerOffset;

    _overlayEntry = OverlayEntry(
      builder: (context) {
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
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: targetAnchor,
              followerAnchor: followerAnchor,
              offset: offset,
              child: Material(
                color: Colors.transparent,
                child: widget.overlayBuilder(_dismissOverlay),
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.childBuilder(_toggleOverlay, _overlayEntry != null),
    );
  }
}
