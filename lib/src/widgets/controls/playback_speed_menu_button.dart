import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player/theme/omni_video_player_theme.dart';
import 'package:omni_video_player/src/widgets/controls/horizontal_control_menu.dart';
import 'package:omni_video_player/src/widgets/controls/overlay_button_wrapper.dart';

import 'video_control_icon_button.dart';

class PlaybackSpeedMenuButton extends StatelessWidget {
  final List<double> speedList;
  final double currentSpeed;
  final void Function(double selectedSpeed) onSpeedSelected;
  final VoidCallback onStartInteraction;
  final VoidCallback onEndInteraction;

  const PlaybackSpeedMenuButton({
    super.key,
    required this.speedList,
    required this.currentSpeed,
    required this.onSpeedSelected,
    required this.onStartInteraction,
    required this.onEndInteraction,
  });

  Widget _buildMenu(
    OmniVideoPlayerThemeData theme,
    VoidCallback dismissOverlay,
  ) {
    final items = speedList
        .map(
          (speed) => HorizontalControlMenuItem(
            label: "${speed}x",
            isSelected: speed == currentSpeed,
            onTap: () {
              onSpeedSelected(speed);
              dismissOverlay();
            },
          ),
        )
        .toList();

    return HorizontalControlMenu(theme: theme, items: items);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmniVideoPlayerTheme.of(context)!;

    return OverlayButtonWrapper(
      targetAnchor: Alignment.bottomCenter,
      followerAnchor: Alignment.topCenter,
      followerOffset: const Offset(0, 6),
      childBuilder: (toggleOverlay, expanded) => VideoControlIconButton(
        semanticLabel: theme.accessibility.playbackSpeedButtonLabel,
        expanded: expanded,
        onPressed: toggleOverlay,
        icon: theme.icons.playbackSpeedButton,
      ),
      overlayBuilder: (dismissOverlay) => _buildMenu(theme, dismissOverlay),
      onStartInteraction: onStartInteraction,
      onEndInteraction: onEndInteraction,
    );
  }
}
