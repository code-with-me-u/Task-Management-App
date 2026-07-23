import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isFullWidth;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isFullWidth = true,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Style configurations based on theme
    final buttonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: isSecondary 
          ? AppConstants.surface 
          : AppConstants.primary,
      foregroundColor: isSecondary 
          ? AppConstants.primary 
          : AppConstants.surface,
      surfaceTintColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingMedium,
        horizontal: AppConstants.paddingLarge,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: isSecondary
            ? const BorderSide(color: AppConstants.border, width: 1.5)
            : BorderSide.none,
      ),
    );

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isSecondary ? AppConstants.primary : AppConstants.surface,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppConstants.paddingSmall),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15.0,
            color: isSecondary ? AppConstants.primary : AppConstants.surface,
          ),
        ),
      ],
    );

    Widget result = ElevatedButton(
      style: buttonStyle,
      onPressed: isLoading ? null : onPressed,
      child: buttonContent,
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: result,
      );
    }
    return result;
  }
}
