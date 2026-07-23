import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      cursorColor: AppConstants.primary,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppConstants.textPrimary,
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        labelStyle: const TextStyle(
          color: AppConstants.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: Colors.black26,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppConstants.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: AppConstants.textSecondary, size: 20) 
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppConstants.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
          horizontal: AppConstants.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppConstants.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppConstants.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppConstants.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppConstants.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppConstants.error, width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: AppConstants.error,
          fontSize: 12,
        ),
      ),
    );
  }
}
