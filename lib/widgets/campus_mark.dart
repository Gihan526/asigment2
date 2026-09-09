import 'package:flutter/material.dart';

/// The campus finder mark exported from the Figma source of truth.
class CampusMark extends StatelessWidget {
  const CampusMark({
    super.key,
    this.width = 138,
    this.height = 120,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/logo4.png',
    width: width,
    height: height,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );
}
