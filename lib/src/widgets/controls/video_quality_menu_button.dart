import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player/models/omni_video_quality.dart';
import 'package:omni_video_player/omni_video_player/theme/omni_video_player_theme.dart';
import 'package:omni_video_player/src/widgets/controls/horizontal_control_menu.dart';
import 'package:omni_video_player/src/widgets/controls/overlay_button_wrapper.dart';

import 'video_control_icon_button.dart';

class VideoQualityMenuButton extends StatelessWidget {
  final List<OmniVideoQuality>? qualityList;
  final OmniVideoQuality? currentQuality;
  final void Function(OmniVideoQuality selectedQuality) onQualitySelected;
  final VoidCallback onStartInteraction;
  final VoidCallback onEndInteraction;

  const VideoQualityMenuButton({
    super.key,
    required this.qualityList,
    required this.currentQuality,
    required this.onQualitySelected,
    required this.onStartInteraction,
    required this.onEndInteraction,
  });

  Widget _buildMenu(
    OmniVideoPlayerThemeData theme,
    VoidCallback dismissOverlay,
  ) {
    final items = qualityList == null
        ? [
            HorizontalControlMenuItem(
              label: currentQuality != null
                  ? "${theme.labels.autoQualityLabel} (${currentQuality!.qualityString})"
                  : theme.labels.autoQualityLabel,
              isSelected: true,
              onTap: dismissOverlay,
              showSelectedIcon: false,
            ),
          ]
        : qualityList!
              .map(
                (quality) => HorizontalControlMenuItem(
                  label: quality.qualityString,
                  isSelected: quality == currentQuality,
                  onTap: () {
                    onQualitySelected(quality);
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
      useFullWidthMenu: true,
      targetAnchor: Alignment.bottomCenter,
      followerAnchor: Alignment.topCenter,
      followerOffset: const Offset(0, 6),
      screenHorizontalMargin: 12,
      childBuilder: (toggleOverlay, expanded) => VideoControlIconButton(
        semanticLabel: theme.accessibility.qualityButtonLabel,
        expanded: expanded,
        onPressed: toggleOverlay,
        icon: theme.icons.qualityChangeButton,
      ),
      overlayBuilder: (dismissOverlay) => _buildMenu(theme, dismissOverlay),
      onStartInteraction: onStartInteraction,
      onEndInteraction: onEndInteraction,
    );
  }
}
