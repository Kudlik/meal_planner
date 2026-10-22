import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/app_text_button.dart';
import '../widgets/shopping_row.dart';

/// "Opcje posiłku" — status / remove actions for a planned meal.
class MealOptionsPanel extends StatelessWidget {
  final String dayKey;
  final String rawMealType;
  final VoidCallback onDone;

  const MealOptionsPanel({
    super.key,
    required this.dayKey,
    required this.rawMealType,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Column(
      children: [
        ShoppingRow(
          name: 'Oznacz posiłek jako przygotowany',
          variant: ShoppingRowVariant.action,
          leadingIcon: 'assets/icons/MealReady.svg',
          onTap: () {
            state.setMealStatus(dayKey, rawMealType, 'prepared');
            onDone();
          },
        ),
        ShoppingRow(
          name: 'Oznacz posiłek jako zjedzony',
          variant: ShoppingRowVariant.action,
          leadingIcon: 'assets/icons/Eaten.svg',
          onTap: () {
            state.setMealStatus(dayKey, rawMealType, 'eaten');
            onDone();
          },
        ),
        ShoppingRow(
          name: 'Usuń przepis z menu',
          variant: ShoppingRowVariant.action,
          leadingIcon: 'assets/icons/Trash.svg',
          onTap: () {
            state.removeFromSlot(dayKey, rawMealType);
            onDone();
          },
        ),
      ],
    );
  }
}

/// Pick a recipe for an empty slot. Not part of the Figma frames, so it reuses
/// the phone picker's behaviour (select a row, confirm with a button) inside
/// the same side panel.
class MealPickerPanel extends StatefulWidget {
  final String dayKey;
  final String rawMealType;
  final VoidCallback onDone;

  const MealPickerPanel({
    super.key,
    required this.dayKey,
    required this.rawMealType,
    required this.onDone,
  });

  @override
  State<MealPickerPanel> createState() => _MealPickerPanelState();
}

class _MealPickerPanelState extends State<MealPickerPanel> {
  String? _selected;

  void _confirm() {
    context.read<AppState>().assignMeal(widget.dayKey, widget.rawMealType, _selected!);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final meals = context.watch<AppState>().mealsForType(widget.rawMealType);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return ShoppingRow(
                name: meal.name,
                variant: ShoppingRowVariant.picker,
                isSelected: _selected == meal.name,
                onTap: () => setState(() => _selected = meal.name),
              );
            },
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppTextButton(
              label: 'Dodaj do menu',
              type: AppTextButtonType.primary,
              onPressed: _confirm,
            ),
          ),
        ],
      ],
    );
  }
}
