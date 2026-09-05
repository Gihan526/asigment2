import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_colors.dart';

void main() => runApp(const CampusLostFoundApp());

class CampusLostFoundApp extends StatelessWidget {
  const CampusLostFoundApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Campus Lost & Found',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
    ),
    home: const LoginScreen(),
  );
}
