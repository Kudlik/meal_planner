import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import 'category_badge.dart';

class AppCategoryDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;

  const AppCategoryDropdown({
    super.key,
    this.value,
    this.onChanged,
  });

  static const categories = [
    'owoce', 'warzywa', 'konserwowe', 'pieczywo', 'tłuszcze',
    'słodycze', 'nabiał', 'mięso', 'sypkie', 'mrożonki', 'higiena',
  ];

  @override
  State<AppCategoryDropdown> createState() => _AppCategoryDropdownState();
}

class _AppCategoryDropdownState extends State<AppCategoryDropdown> {
  bool _isOpen = false;

  static const _borderRadius = BorderRadius.only(
    topLeft: Radius.circular(3),
    topRight: Radius.circular(3),
  );

  static const _hintStyle = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
    letterSpacing: 0.5,
    color: AppColors.accentSurface,
  );

  Color get _borderColor => _isOpen ? AppColors.accent : AppColors.accentSurface;

  Widget get _label => widget.value != null
      ? CategoryBadge(category: widget.value)
      : const Text('Kategoria', style: _hintStyle);

  Widget _icon(String asset) => SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(_borderColor, BlendMode.srcIn),
      );

  void _toggle() => setState(() => _isOpen = !_isOpen);

  void _select(String category) {
    widget.onChanged?.call(category);
    setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textDark,
          borderRadius: _borderRadius,
          border: Border(
            bottom: BorderSide(color: _borderColor, width: 1),
          ),
        ),
        child: _isOpen ? _buildOpen() : _buildClosed(),
      ),
    );
  }

  Widget _buildClosed() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _label,
          const SizedBox(width: 11),
          _icon('assets/icons/Dropdown.svg'),
        ],
      ),
    );
  }

  Widget _buildOpen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Categories appear above the trigger row
          ...AppCategoryDropdown.categories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GestureDetector(
                  onTap: () => _select(cat),
                  child: CategoryBadge(category: cat),
                ),
              )),
          // Trigger row stays at the bottom
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _label,
              const SizedBox(width: 11),
              _icon('assets/icons/DropdownUp.svg'),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
