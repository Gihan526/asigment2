import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../theme/app_colors.dart';
import '../widgets/access_note.dart';
import '../widgets/campus_mark.dart';
import '../widgets/login_text_field.dart';

/// The welcome-back screen from the Campus Lost & Found Figma flow.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _designWidth = 440.0;
  static const _designHeight = 956.0;

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.pageBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final surfaceWidth = math.min(constraints.maxWidth, _designWidth);
            final surfaceHeight = math.max(
              constraints.maxHeight,
              _designHeight,
            );

            return SingleChildScrollView(
              child: Center(
                child: Container(
                  width: surfaceWidth,
                  height: surfaceHeight,
                  decoration: BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius: BorderRadius.circular(44),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 14,
                        top: 49,
                        child: _BackButton(
                          onTap: () => Navigator.maybePop(context),
                        ),
                      ),
                      const Positioned(
                        top: 72,
                        left: 0,
                        right: 0,
                        child: Center(child: CampusMark()),
                      ),
                      const Positioned(
                        top: 213,
                        left: 32,
                        right: 32,
                        child: Text(
                          'CAMPUS LOST & FOUND',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 17 / 12,
                            letterSpacing: .96,
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 254,
                        left: 32,
                        right: 32,
                        child: Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 44 / 32,
                            letterSpacing: -.65,
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 304,
                        left: 46,
                        right: 46,
                        child: Text(
                          'Sign in to continue helping items find their way\nhome.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 21 / 15,
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 371,
                        left: 32,
                        right: 32,
                        child: _FieldLabel('Campus email'),
                      ),
                      const Positioned(
                        top: 396,
                        left: 32,
                        right: 32,
                        child: LoginTextField(
                          hint: 'name@campus.edu',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const Positioned(
                        top: 475,
                        left: 32,
                        child: _FieldLabel('Password'),
                      ),
                      Positioned(
                        top: 469,
                        right: 22,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.blue,
                            minimumSize: const Size(0, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 18 / 13,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 500,
                        left: 32,
                        right: 32,
                        child: LoginTextField(
                          hint: 'Enter your password',
                          obscureText: _hidePassword,
                          suffix: _PasswordVisibilityButton(
                            hidden: _hidePassword,
                            onTap: () =>
                                setState(() => _hidePassword = !_hidePassword),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 592,
                        left: 32,
                        right: 32,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x402563EB),
                                blurRadius: 18,
                                spreadRadius: -4,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 22 / 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 694,
                        left: 24,
                        right: 24,
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Flexible(
                              child: Text(
                                'New to Campus Lost & Found?',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 19 / 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.blue,
                                minimumSize: const Size(0, 38),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 19 / 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: 765,
                        left: 32,
                        right: 32,
                        height: 84,
                        child: AccessNote(),
                      ),
                      Positioned(
                        bottom: 23,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 134,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.primaryText,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Back',
    child: SizedBox(
      width: 64,
      height: 64,
      child: Center(
        child: Material(
          color: Colors.white,
          elevation: 2,
          shadowColor: const Color(0x260F1724),
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.inputBorder),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                TablerIcons.chevron_left,
                size: 29,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PasswordVisibilityButton extends StatelessWidget {
  const _PasswordVisibilityButton({required this.hidden, required this.onTap});

  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: hidden ? 'Show password' : 'Hide password',
    padding: EdgeInsets.zero,
    icon: Icon(
      hidden ? TablerIcons.eye : TablerIcons.eye_off,
      color: const Color(0xFF737373),
      size: 23,
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.primaryText,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 18 / 13,
    ),
  );
}
