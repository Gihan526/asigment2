import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../theme/app_colors.dart';
import '../widgets/campus_mark.dart';
import '../widgets/login_text_field.dart';
import '../widgets/theme_toggle_button.dart';

/// The registration screen for creating a new Foundly campus account.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const _maxFormWidth = 440.0;

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxFormWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: _BackButton(
                                  onTap: () => Navigator.maybePop(context),
                                ),
                              ),
                              const CampusMark(width: 90, height: 78),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'FOUNDLY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 17 / 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 38 / 30,
                            letterSpacing: -.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Join your campus community to report and recover lost items.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 20 / 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Full name'),
                        const SizedBox(height: 6),
                        LoginTextField(
                          controller: _nameController,
                          hint: 'Alex Morgan',
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        const _FieldLabel('Campus email'),
                        const SizedBox(height: 6),
                        LoginTextField(
                          controller: _emailController,
                          hint: 'name@campus.edu',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        const _FieldLabel('Password'),
                        const SizedBox(height: 6),
                        LoginTextField(
                          controller: _passwordController,
                          hint: 'Create a password',
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.next,
                          suffix: _PasswordVisibilityButton(
                            hidden: _hidePassword,
                            onTap: () =>
                                setState(() => _hidePassword = !_hidePassword),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _FieldLabel('Confirm password'),
                        const SizedBox(height: 6),
                        LoginTextField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm your password',
                          obscureText: _hideConfirmPassword,
                          textInputAction: TextInputAction.done,
                          suffix: _PasswordVisibilityButton(
                            hidden: _hideConfirmPassword,
                            onTap: () => setState(
                              () =>
                                  _hideConfirmPassword = !_hideConfirmPassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 54,
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.yellow,
                              foregroundColor: AppColors.lightPrimaryText,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 22 / 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Already have an account?',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 19 / 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Navigator.maybePop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primary,
                                minimumSize: const Size(0, 38),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 19 / 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 20,
                child: ThemeToggleButton(onPressed: widget.onToggleTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: colors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: .15),
        shape: CircleBorder(side: BorderSide(color: colors.outline)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              TablerIcons.chevron_left,
              size: 24,
              color: colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordVisibilityButton extends StatelessWidget {
  const _PasswordVisibilityButton({required this.hidden, required this.onTap});

  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onTap,
      tooltip: hidden ? 'Show password' : 'Hide password',
      padding: EdgeInsets.zero,
      icon: Icon(
        hidden ? TablerIcons.eye : TablerIcons.eye_off,
        color: colors.onSurfaceVariant,
        size: 23,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 18 / 13,
    ),
  );
}
