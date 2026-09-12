import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// Explains why sign-in is limited to campus accounts.
class AccessNote extends StatelessWidget {
  const AccessNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.primary,
            child: Icon(TablerIcons.check, color: colors.onPrimary, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus-only access',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 19 / 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your account keeps reports connected to real people.',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 12,
                    height: 17 / 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
