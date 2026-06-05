import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BottomDrawer extends StatelessWidget {
  final String title;
  final Widget child;

  const BottomDrawer({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.textSecondary, // Schemes/Outline #7C7767
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.accentBright, // #FAE287
            ),
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border, // Schemes/Outline Variant #CDC6B4
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
