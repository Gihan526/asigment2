import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../theme/app_colors.dart';

/// Explains why sign-in is limited to campus accounts.
class AccessNote extends StatelessWidget {
  const AccessNote({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: AppColors.accessCard,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.blue,
          child: Icon(TablerIcons.check, color: Colors.white, size: 21),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campus-only access',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 19 / 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your account keeps reports connected to real people.',
                style: TextStyle(
                  color: AppColors.secondaryText,
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
