import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String _sans    = 'Epilogue';
  static const String _display = 'GowunBatang';

  // ── Display (splash / hero) ───────────────────────────────────────────────
  static const TextStyle displayHero = TextStyle(
    fontFamily: _display,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
  );

  static const TextStyle displaySubtitle = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
  );

  // ── Headline ─────────────────────────────────────────────────────────────
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _display,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 32 / 24,
    color: AppColors.textOnAccent, // #675E40
  );

  // ── Navigation ────────────────────────────────────────────────────────────
  static const TextStyle navLabel = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnAccent,
  );

  static const TextStyle tabLabel = TextStyle(
    fontFamily: _sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // ── Day selector ──────────────────────────────────────────────────────────
  static const TextStyle daySelectorLabel = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ── Meal grid ─────────────────────────────────────────────────────────────
  static const TextStyle mealTypeLabel = TextStyle(
    fontFamily: _sans,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnCard,
    letterSpacing: 0.3,
  );

  static const TextStyle mealTitle = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnCard,
    height: 1.3,
  );

  static const TextStyle mealSubtitle = TextStyle(
    fontFamily: _sans,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnCard,
  );

  // ── Shopping list ─────────────────────────────────────────────────────────
  static const TextStyle listItemName = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle listItemNameStruck = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
    decorationColor: AppColors.textSecondary,
  );

  static const TextStyle listItemQuantity = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ── Badges ────────────────────────────────────────────────────────────────
  static const TextStyle badgeText = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textLabel, // Schemes/Primary #6E5D0E
    height: 16 / 12,
    letterSpacing: 0.5,
  );

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const TextStyle emptyStateText = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle pickerItemName = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}
