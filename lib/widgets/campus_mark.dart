import 'package:flutter/material.dart';

/// The campus finder mark exported from the Figma source of truth.
class CampusMark extends StatelessWidget {
  const CampusMark({super.key});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/campus_mark.png',
    width: 160,
    height: 160,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );
}
