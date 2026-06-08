import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player/controllers/omni_playback_controller.dart';
import 'package:omni_video_player/omni_video_player/theme/omni_video_player_theme.dart';
import 'package:omni_video_player/src/utils/accessibility/accessible.dart';
import 'package:omni_video_player/src/widgets/controls/overlay_button_wrapper.dart';

import 'video_control_icon_button.dart';

class _FitOption {
  final BoxFit fit;
  final String label;

  const _FitOption(this.fit, this.label);
}

const _fitOptions = [
  _FitOption(BoxFit.contain, 'Fit ratio'),
  _FitOption(BoxFit.cover, 'Fill screen'),
  _FitOption(BoxFit.fill, 'Stretch'),
];

class FullscreenVideoFitMenuButton extends StatelessWidget {
  final OmniPlaybackController controller;
  final VoidCallback onStartInteraction;
  final VoidCallback onEndInteraction;

  const FullscreenVideoFitMenuButton({
    super.key,
    required this.controller,
    required this.onStartInteraction,
    required this.onEndInteraction,
  });

  Widget _buildMenu(
    OmniVideoPlayerThemeData theme,
    VoidCallback dismissOverlay,
  ) {
    return Card(
      elevation: 8,
      color: theme.colors.menuBackground,
      child: Container(
        width: 140,
        decoration:
            theme.menus.menuDecoration ??
            BoxDecoration(
              color: theme.colors.menuBackground,
              borderRadius: BorderRadius.circular(
                theme.shapes.menuBorderRadius,
              ),
            ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          children: _fitOptions.map((option) {
            final isSelected = controller.fullscreenVideoFit == option.fit;
            return Accessible.clickable(
              onTap: () {
                controller.setFullscreenVideoFit(option.fit);
                dismissOverlay();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colors.menuTextSelected
                              : theme.colors.menuText,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        theme.icons.qualitySelectedCheck,
                        color: theme.colors.menuIconSelected,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmniVideoPlayerTheme.of(context)!;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return OverlayButtonWrapper(
          openMenuAbove: true,
          followerOffset: const Offset(0, 6),
          childBuilder: (toggleOverlay, expanded) => VideoControlIconButton(
            semanticLabel: 'Change fullscreen video fit',
            expanded: expanded,
            onPressed: toggleOverlay,
            icon: Icons.aspect_ratio,
          ),
          overlayBuilder: (dismissOverlay) =>
              _buildMenu(theme, dismissOverlay),
          onStartInteraction: onStartInteraction,
          onEndInteraction: onEndInteraction,
        );
      },
    );
  }
}
