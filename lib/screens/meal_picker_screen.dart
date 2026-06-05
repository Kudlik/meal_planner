import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/top_navigation.dart';
import '../widgets/shopping_row.dart';
import '../widgets/app_text_button.dart';

class MealPickerScreen extends StatefulWidget {
  final String dayKey;
  final String rawMealType;
  final String displayMealType; // accusative, e.g. 'obiad'

  const MealPickerScreen({
    super.key,
    required this.dayKey,
    required this.rawMealType,
    required this.displayMealType,
  });

  @override
  State<MealPickerScreen> createState() => _MealPickerScreenState();
}

class _MealPickerScreenState extends State<MealPickerScreen> {
  String? _selectedMealName;

  void _confirm() {
    context.read<AppState>().assignMeal(
          widget.dayKey,
          widget.rawMealType,
          _selectedMealName!,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final meals = context.watch<AppState>().mealsForType(widget.rawMealType);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopNavigation(
              title: 'Wybierz ${widget.displayMealType}',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return ShoppingRow(
                    name: meal.name,
                    variant: ShoppingRowVariant.picker,
                    isSelected: _selectedMealName == meal.name,
                    onTap: () => setState(() => _selectedMealName = meal.name),
                  );
                },
              ),
            ),
            if (_selectedMealName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: AppTextButton(
                  label: 'Dodaj do menu',
                  type: AppTextButtonType.primary,
                  onPressed: _confirm,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
