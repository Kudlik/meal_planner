import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class MealCard extends StatelessWidget {
  final String? mealName; // null → empty state
  final String? source;
  final int? page;
  final String label; // e.g. "Dodaj\nśniadanie" — shown in empty state
  final VoidCallback? onTap;

  final double? width;  // null = fill parent
  final double? height; // null = fill parent

  const MealCard({
    super.key,
    this.mealName,
    this.source,
    this.page,
    required this.label,
    this.onTap,
    this.width,
    this.height,
  });

  bool get _isEmpty => mealName == null;

  static const _labelStyle = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
    color: AppColors.textOnCard,
  );

  static const _sourceStyle = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 8,
    fontWeight: FontWeight.w400,
    height: 16 / 8,
    letterSpacing: 0.4,
    color: AppColors.textOnCard,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: _isEmpty
            ? const EdgeInsets.all(6)
            : const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _isEmpty ? _buildEmpty() : _buildFull(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.textOnCard, // #C5ECCD mint
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            'assets/icons/Add.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.surface, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: _labelStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFull() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              mealName!,
              style: _labelStyle,
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (source != null && source!.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Text(source!, style: _sourceStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        if (page != null && page! > 0)
          Align(
            alignment: Alignment.centerRight,
            child: Text('str. $page', style: _sourceStyle),
          ),
      ],
    );
  }
}
