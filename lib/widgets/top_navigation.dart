import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TopNavigation extends StatelessWidget {
  final String title;
  final VoidCallback? onBack; // convenience: renders the Back.svg icon
  final Widget? leading;      // overrides onBack when provided
  final Widget? trailing;
  final VoidCallback? onTitleTap;

  const TopNavigation({
    super.key,
    required this.title,
    this.onBack,
    this.leading,
    this.trailing,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.accentMid, // #EFE2BC
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 24),
          ] else if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: SvgPicture.asset(
                'assets/icons/Back.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.textOnAccent, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 24),
          ],
          Expanded(
            child: GestureDetector(
              onTap: onTitleTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                title,
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 24),
            trailing!,
          ],
        ],
      ),
    );
  }
}
