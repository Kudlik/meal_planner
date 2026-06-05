import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CategoryBadge extends StatelessWidget {
  final String? category;
  final bool disabled;

  const CategoryBadge({super.key, this.category, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    if (category == null) return const SizedBox.shrink();

    final label = _capitalize(category!);
    final bg  = disabled ? AppColors.borderNeutral      : AppColors.badgeColor(category);
    final fg  = disabled ? AppColors.disabled           : AppColors.badgeTextColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.badgeText.copyWith(color: fg),
        maxLines: 1,
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
