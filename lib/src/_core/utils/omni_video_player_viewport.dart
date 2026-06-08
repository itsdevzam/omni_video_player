import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player/controllers/omni_playback_controller.dart';

/// A widget that displays a video player and adapts its aspect ratio
/// based on the video's rotation.
class OmniVideoPlayerViewport extends StatelessWidget {
  final OmniPlaybackController controller;
  final bool isFullScreenDisplay;
  final double aspectRatio;
  final BoxFit? fullscreenFit;

  const OmniVideoPlayerViewport({
    super.key,
    required this.controller,
    required this.isFullScreenDisplay,
    required this.aspectRatio,
    this.fullscreenFit,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller,
        controller.sharedPlayerNotifier,
      ]),
      builder: (context, _) {
        final player = controller.sharedPlayerNotifier.value;
        final shouldRender = isFullScreenDisplay == controller.isFullScreen;
        final ratio = aspectRatio > 0 ? aspectRatio : 16 / 9;

        final videoChild = shouldRender
            ? (player ?? const SizedBox.shrink())
            : const SizedBox.shrink();

        if (isFullScreenDisplay && fullscreenFit == BoxFit.cover) {
          final width = ratio >= 1 ? ratio : 1.0;
          final height = ratio >= 1 ? 1.0 : 1.0 / ratio;

          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: width * 1000,
                height: height * 1000,
                child: videoChild,
              ),
            ),
          );
        }

        return AspectRatio(
          aspectRatio: ratio,
          child: videoChild,
        );
      },
    );
  }
}
