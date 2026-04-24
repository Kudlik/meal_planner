import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MealPickerScreen extends StatefulWidget {
  final String dayKey;
  final String rawMealType;
  final String displayMealType;

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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final meals = state.mealsForType(widget.rawMealType);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Dodaj ${widget.displayMealType.toLowerCase()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: meals.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final meal = meals[index];
                final isSelected = _selectedMealName == meal.name;
                return _MealPickerRow(
                  meal: meal,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedMealName = meal.name),
                );
              },
            ),
          ),
          if (_selectedMealName != null) _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.read<AppState>().assignMeal(
                    widget.dayKey,
                    widget.rawMealType,
                    _selectedMealName!,
                  );
              Navigator.pop(context);
            },
            child: const Text('Dodaj posiłek do menu',
                style: AppTextStyles.buttonLabel),
          ),
        ),
      ),
    );
  }
}

class _MealPickerRow extends StatelessWidget {
  final Meal meal;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealPickerRow({
    required this.meal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                meal.name,
                style: AppTextStyles.pickerItemName.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
