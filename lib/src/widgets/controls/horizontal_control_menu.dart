import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player/theme/omni_video_player_theme.dart';
import 'package:omni_video_player/src/utils/accessibility/accessible.dart';

class HorizontalControlMenuItem {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showSelectedIcon;

  const HorizontalControlMenuItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showSelectedIcon = true,
  });
}

/// Scrollable horizontal strip for player option menus (quality, speed, etc.).
class HorizontalControlMenu extends StatelessWidget {
  final OmniVideoPlayerThemeData theme;
  final List<HorizontalControlMenuItem> items;

  const HorizontalControlMenu({
    super.key,
    required this.theme,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - 24;

    return Card(
      elevation: 8,
      color: theme.colors.menuBackground,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration:
            theme.menus.menuDecoration ??
            BoxDecoration(
              color: theme.colors.menuBackground,
              borderRadius: BorderRadius.circular(
                theme.shapes.menuBorderRadius,
              ),
            ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items) ...[
                Accessible.clickable(
                  onTap: item.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: item.isSelected
                          ? theme.colors.menuTextSelected.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        theme.shapes.menuBorderRadius,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            color: item.isSelected
                                ? theme.colors.menuTextSelected
                                : theme.colors.menuText,
                            fontWeight: item.isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (item.isSelected &&
                            item.showSelectedIcon &&
                            items.length > 1)
                          Icon(
                            theme.icons.qualitySelectedCheck,
                            color: theme.colors.menuIconSelected,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
