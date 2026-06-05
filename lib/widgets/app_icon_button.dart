import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

enum AppIconButtonType { primary, secondary, tertiary }

class AppIconButton extends StatelessWidget {
  final String iconAsset; // e.g. 'assets/icons/Back.svg'
  final VoidCallback? onPressed;
  final AppIconButtonType type;

  const AppIconButton({
    super.key,
    required this.iconAsset,
    this.onPressed,
    this.type = AppIconButtonType.primary,
  });

  Color get _background {
    switch (type) {
      case AppIconButtonType.primary:   return AppColors.accentBright; // #FAE287
      case AppIconButtonType.secondary: return AppColors.accentMid;   // #EFE2BC
      case AppIconButtonType.tertiary:  return AppColors.textOnCard;  // #C5ECCD
    }
  }

  Color get _iconColor {
    switch (type) {
      case AppIconButtonType.primary:   return AppColors.textLabel;    // #6E5D0E
      case AppIconButtonType.secondary: return AppColors.textOnAccent; // #675E40
      case AppIconButtonType.tertiary:  return AppColors.surfaceLight; // #44664E
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: _background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: SvgPicture.asset(
              iconAsset,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(_iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
