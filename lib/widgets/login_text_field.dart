import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
  });
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: BorderSide(color: colors.outline),
    );

    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        obscureText: obscureText,
        style: TextStyle(color: colors.onSurface, fontSize: 15, height: 1.4),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF7F8998) : const Color(0xFF939393),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints.tightFor(width: 62),
          filled: true,
          fillColor: isDark ? theme.scaffoldBackgroundColor : colors.surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18.5,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
