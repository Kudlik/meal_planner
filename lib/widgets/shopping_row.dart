import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import 'category_badge.dart';

enum ShoppingRowVariant { list, picker, action }

class ShoppingRow extends StatelessWidget {
  final String name;
  final ShoppingRowVariant variant;

  // list-only
  final String quantity;
  final String? category;
  final bool isBought;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;

  // picker + action
  final VoidCallback? onTap;
  final bool isSelected; // picker variant only

  // action-only
  final String? leadingIcon; // SVG asset path, e.g. 'assets/icons/Share.svg'

  const ShoppingRow({
    super.key,
    required this.name,
    this.variant = ShoppingRowVariant.list,
    this.quantity = '',
    this.category,
    this.isBought = false,
    this.onToggle,
    this.onEdit,
    this.onTap,
    this.isSelected = false,
    this.leadingIcon,
  });

  static const _defaultStyle = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static const _checkedStyle = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
    color: AppColors.textOnCard,
    decoration: TextDecoration.lineThrough,
    decorationColor: AppColors.textOnCard,
    decorationThickness: 2.0,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: variant != ShoppingRowVariant.list ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLeading(),
            const SizedBox(width: 12),
            ..._buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    switch (variant) {
      case ShoppingRowVariant.list:
        return GestureDetector(
          onTap: onToggle,
          child: SvgPicture.asset(
            isBought
                ? 'assets/icons/CheckboxFilled.svg'
                : 'assets/icons/CehckboxEmpty.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isBought ? AppColors.textOnCard : AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
        );
      case ShoppingRowVariant.picker:
        return SvgPicture.asset(
          isSelected
              ? 'assets/icons/RadioChecked.svg'
              : 'assets/icons/Radio.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isSelected ? AppColors.accent : AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        );
      case ShoppingRowVariant.action:
        return SvgPicture.asset(
          leadingIcon ?? 'assets/icons/Add.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
        );
    }
  }

  List<Widget> _buildTrailing() {
    final textStyle = isBought ? _checkedStyle : _defaultStyle;

    switch (variant) {
      case ShoppingRowVariant.list:
        return [
          Expanded(
            child: Text(name, style: textStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          if (quantity.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(quantity, style: textStyle),
          ],
          if (category != null) ...[
            const SizedBox(width: 12),
            CategoryBadge(category: category, disabled: isBought),
          ],
          if (!isBought && onEdit != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onEdit,
              child: SvgPicture.asset(
                'assets/icons/Edit.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
              ),
            ),
          ],
        ];
      case ShoppingRowVariant.picker:
      case ShoppingRowVariant.action:
        return [
          Expanded(
            child: Text(name, style: _defaultStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ];
    }
  }
}
