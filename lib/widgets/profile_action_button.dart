import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// A circular header button that matches the exact styling, geometry,
/// border, and elevation of [ThemeToggleButton] for visual harmony in app bars.
class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    super.key,
    required this.onPressed,
    this.size = 42.0,
    this.name = '',
  });

  final VoidCallback onPressed;
  final double size;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Open user profile',
      child: Material(
        color: isDark ? theme.scaffoldBackgroundColor : colors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: isDark ? .32 : .12),
        shape: CircleBorder(side: BorderSide(color: colors.outline)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox.square(
          dimension: size,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            tooltip: 'My Profile',
            iconSize: 20,
            color: colors.onSurface,
            icon: const Icon(TablerIcons.user),
          ),
        ),
      ),
    );
  }
}
