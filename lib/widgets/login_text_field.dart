import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
  Widget build(BuildContext context) => Container(
    height: 58,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D0F1724),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      obscureText: obscureText,
      style: const TextStyle(
        color: AppColors.primaryText,
        fontSize: 15,
        height: 1.4,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.tertiaryText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints.tightFor(width: 62),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18.5,
        ),
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
      ),
    ),
  );
}

final _border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(32),
  borderSide: const BorderSide(color: AppColors.inputBorder),
);
