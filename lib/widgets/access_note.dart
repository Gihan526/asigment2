import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../theme/app_colors.dart';

/// Explains why sign-in is limited to campus accounts.
class AccessNote extends StatelessWidget {
  const AccessNote({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.accessCard,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Stack(
      children: [
        Positioned(
          left: 18,
          top: 24,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.blue,
            child: Icon(TablerIcons.check, color: Colors.white, size: 21),
          ),
        ),
        Positioned(
          left: 70,
          top: 15,
          right: 18,
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
              SizedBox(height: 6),
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
