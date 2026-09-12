import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// A persistent auth-screen control for switching between light and dark mode.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      child: Material(
        color: isDark ? theme.scaffoldBackgroundColor : colors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: isDark ? .32 : .12),
        shape: CircleBorder(side: BorderSide(color: colors.outline)),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: onPressed,
          tooltip: isDark ? 'Light mode' : 'Dark mode',
          iconSize: 21,
          color: colors.onSurface,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween<double>(begin: .85, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isDark ? TablerIcons.sun : TablerIcons.moon,
              key: ValueKey(isDark),
            ),
          ),
        ),
      ),
    );
  }
}
