import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppTextButtonType { primary, secondary, tertiary }

class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppTextButtonType type;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppTextButtonType.primary,
  });

  Color get _background {
    switch (type) {
      case AppTextButtonType.primary:   return AppColors.accentBright; // #FAE287
      case AppTextButtonType.secondary: return AppColors.accentMid;   // #EFE2BC
      case AppTextButtonType.tertiary:  return AppColors.textOnCard;  // #C5ECCD
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: _background,
        foregroundColor: AppColors.textOnAccent,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: AppTextStyles.buttonLabel),
    );
  }
}
