import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'meal_picker_screen.dart';

const _dayKeys = ['1-2', '3-4', '5-6', '7-8'];

const _mealRows = [
  ('Śniadanie', 'Śniadanie'),
  ('Deser',     'Lunch'),
  ('Lunch',     'Obiad'),
  ('Kolacja',   'Kolację'),
];

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () => context.read<AppState>().clearPlan(),
                child: const Text(
                  'Wyczyść plan',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildDayHeader(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < _mealRows.length; i++) ...[
                  Expanded(
                    child: _MealTypeRow(
                      rawMealType: _mealRows[i].$1,
                      displayLabel: _mealRows[i].$2,
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                ],
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  static Widget _buildDayHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: _dayKeys.map((day) => Expanded(
          child: Center(
            child: Text(
              'Dni\n$day',
              textAlign: TextAlign.center,
              style: AppTextStyles.mealTypeLabel,
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _MealTypeRow extends StatelessWidget {
  final String rawMealType;
  final String displayLabel;

  const _MealTypeRow({required this.rawMealType, required this.displayLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _dayKeys.length; i++) ...[
          if (i > 0) const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
          Expanded(
            child: _MealCell(
              dayKey: _dayKeys[i],
              rawMealType: rawMealType,
              displayMealType: displayLabel,
            ),
          ),
        ],
      ],
    );
  }
}

class _MealCell extends StatelessWidget {
  final String dayKey;
  final String rawMealType;
  final String displayMealType;

  const _MealCell({
    required this.dayKey,
    required this.rawMealType,
    required this.displayMealType,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final slot = state.slotFor(dayKey, rawMealType);
    final mealName = slot?.mealName;
    final meal = mealName != null ? state.mealInfo(mealName) : null;

    return Container(
      child: mealName == null
          ? _AddButton(
              displayMealType: displayMealType,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MealPickerScreen(
                    dayKey: dayKey,
                    rawMealType: rawMealType,
                    displayMealType: displayMealType,
                  ),
                ),
              ),
            )
          : _MealCard(
              mealName: mealName,
              source: meal?.source ?? '',
              page: meal?.page ?? 0,
              onDelete: () => context.read<AppState>().removeFromSlot(dayKey, rawMealType),
            ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String displayMealType;
  final VoidCallback onTap;

  const _AddButton({required this.displayMealType, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline, size: 28, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                'Dodaj\n${displayMealType.toLowerCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String mealName;
  final String source;
  final int page;
  final VoidCallback onDelete;

  const _MealCard({
    required this.mealName,
    required this.source,
    required this.page,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                mealName,
                style: AppTextStyles.mealTitle.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(source, style: AppTextStyles.mealSubtitle, textAlign: TextAlign.center, maxLines: 1),
              const SizedBox(height: 2),
              Text('str. $page', style: AppTextStyles.mealSubtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
