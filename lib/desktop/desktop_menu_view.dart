import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/meal_card.dart';
import '../widgets/meal_type_cell.dart';
import 'desktop_panels.dart';
import 'desktop_shell.dart';

// ($1 = rawMealType used as data key, $2 = display label in accusative case)
const _mealRows = [
  ('Śniadanie', 'śniadanie'),
  ('Deser',     'deser'),
  ('Lunch',     'obiad'),
  ('Kolacja',   'kolację'),
];

const _dayKeys = ['1-2', '3-4', '5-6', '7-8'];

/// All four day-pairs side by side (no swiping), with the meal-type labels
/// repeated as an invisible gutter so the cards line up as in the design.
class DesktopMenuView extends StatelessWidget {
  const DesktopMenuView({super.key});

  static const _columnGap = 33.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _dayKeys.length; i++) ...[
          if (i > 0) const SizedBox(width: _columnGap),
          Expanded(child: _DayColumn(dayKey: _dayKeys[i], showLabels: i == 0)),
        ],
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  final String dayKey;
  final bool showLabels;

  const _DayColumn({required this.dayKey, required this.showLabels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, right: 12, bottom: 24),
      child: Column(
        children: [
          _DayBadge(label: dayKey),
          for (final row in _mealRows) ...[
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: showLabels
                        ? Center(child: MealTypeCell(label: row.$1))
                        : null,
                  ),
                  Expanded(
                    child: _MealSlot(
                      dayKey: dayKey,
                      rawMealType: row.$1,
                      displayLabel: row.$2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  final String label;
  const _DayBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.textOnCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Epilogue',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 16 / 12,
          letterSpacing: 0.4,
          color: AppColors.surfaceLight,
        ),
      ),
    );
  }
}

class _MealSlot extends StatelessWidget {
  final String dayKey;
  final String rawMealType;
  final String displayLabel;

  const _MealSlot({
    required this.dayKey,
    required this.rawMealType,
    required this.displayLabel,
  });

  static const _cardHeight = 142.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final slot = state.slotFor(dayKey, rawMealType);
    final mealName = slot?.mealName;
    final meal = mealName != null ? state.mealInfo(mealName) : null;
    final panel = DesktopPanelScope.of(context);

    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: MealCard(
            mealName: mealName,
            source: meal?.source,
            page: meal?.page,
            label: 'Dodaj $displayLabel',
            status: slot?.status,
            width: constraints.maxWidth,
            height: constraints.maxHeight < _cardHeight
                ? constraints.maxHeight
                : _cardHeight,
            onTap: mealName == null
                ? () => panel.open(
                      'Wybierz $displayLabel',
                      MealPickerPanel(
                        key: ValueKey('pick-$dayKey-$rawMealType'),
                        dayKey: dayKey,
                        rawMealType: rawMealType,
                        onDone: panel.close,
                      ),
                      scrollable: false,
                    )
                : () => panel.open(
                      'Opcje posiłku:',
                      MealOptionsPanel(
                        dayKey: dayKey,
                        rawMealType: rawMealType,
                        onDone: panel.close,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
