import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          color: theme.textPrimary,
          fontSize: 16,
        ),
        cursorColor: theme.accent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.textSecondary,
            fontSize: 14,
          ),
          floatingLabelStyle: TextStyle(
            color: theme.accent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.surfaceLight.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.accent,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.error,
              width: 2,
            ),
          ),
          prefixIcon: prefixIcon != null
              ? IconTheme(
                  data: IconThemeData(
                    color: theme.textSecondary,
                  ),
                  child: prefixIcon!,
                )
              : null,
          filled: true,
          fillColor: theme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }
} 