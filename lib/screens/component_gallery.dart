import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_text_button.dart';
import '../widgets/app_input_field.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/category_badge.dart';
import '../widgets/app_category_dropdown.dart';
import '../widgets/meal_card.dart';
import '../widgets/shopping_row.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/day_selector.dart';
import '../widgets/meal_type_cell.dart';
import '../widgets/top_navigation.dart';
import '../widgets/bottom_drawer.dart';

class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Component Gallery',
          style: TextStyle(
            fontFamily: 'Epilogue',
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Section(title: 'Text Button'),
          _Row(label: 'Primary', child: AppTextButton(label: 'To jest przycisk', type: AppTextButtonType.primary)),
          _Row(label: 'Secondary', child: AppTextButton(label: 'To jest przycisk', type: AppTextButtonType.secondary)),
          _Row(label: 'Tertiary', child: AppTextButton(label: 'To jest przycisk', type: AppTextButtonType.tertiary)),

          _Section(title: 'Icon Button'),
          _Row(label: 'Primary',   expand: false, child: AppIconButton(iconAsset: 'assets/icons/Back.svg', type: AppIconButtonType.primary)),
          _Row(label: 'Secondary', expand: false, child: AppIconButton(iconAsset: 'assets/icons/Back.svg', type: AppIconButtonType.secondary)),
          _Row(label: 'Tertiary',  expand: false, child: AppIconButton(iconAsset: 'assets/icons/Back.svg', type: AppIconButtonType.tertiary)),

          _Section(title: 'Category Tag'),
          _Row(label: 'Konserwowe', expand: false, child: CategoryBadge(category: 'konserwowe')),
          _Row(label: 'Owoce',      expand: false, child: CategoryBadge(category: 'owoce')),
          _Row(label: 'Warzywa',    expand: false, child: CategoryBadge(category: 'warzywa')),
          _Row(label: 'Nabiał',     expand: false, child: CategoryBadge(category: 'nabiał')),
          _Row(label: 'Mrożonki',   expand: false, child: CategoryBadge(category: 'mrożonki')),
          _Row(label: 'Mięso',      expand: false, child: CategoryBadge(category: 'mięso')),
          _Row(label: 'Sypkie',     expand: false, child: CategoryBadge(category: 'sypkie')),
          _Row(label: 'Pieczywo',   expand: false, child: CategoryBadge(category: 'pieczywo')),
          _Row(label: 'Słodycze',   expand: false, child: CategoryBadge(category: 'słodycze')),
          _Row(label: 'Tłuszcze',   expand: false, child: CategoryBadge(category: 'tłuszcze')),
          _Row(label: 'Higiena',    expand: false, child: CategoryBadge(category: 'higiena')),
          _Row(label: 'Disabled',   expand: false, child: CategoryBadge(category: 'owoce', disabled: true)),

          _Section(title: 'Dropdown'),
          _Row(label: 'Closed',   child: AppCategoryDropdown(value: null, onChanged: (_) {})),
          _Row(label: 'Selected', child: AppCategoryDropdown(value: 'owoce', onChanged: (_) {})),

          _Section(title: 'Meal Card'),
          _Row(label: 'Empty',   expand: false, child: MealCard(width: 105, height: 150, label: 'Dodaj\nśniadanie')),
          _Row(label: 'Full',    expand: false, child: MealCard(width: 105, height: 150, mealName: 'Makaron penne w sosie pomidorowym z pieczarkami i szpinakiem', source: 'Wysokobiałkowe', page: 77, label: '')),

          _Section(title: 'Shopping Row'),
          ShoppingRow(name: 'Element listy', quantity: '35g', category: 'konserwowe', isBought: false, onToggle: () {}, onEdit: () {}),
          ShoppingRow(name: 'Element listy', quantity: '35g', category: 'konserwowe', isBought: true, onToggle: () {}),
          ShoppingRow(name: 'Placuszki czekoladowe z twarożkiem', variant: ShoppingRowVariant.picker, onTap: () {}),
          ShoppingRow(name: 'Usuń posiłek z menu', variant: ShoppingRowVariant.action, leadingIcon: 'assets/icons/Trash.svg', onTap: () {}),

          _Section(title: 'Top Navigation'),
          TopNavigation(title: 'Wybierz śniadanie', onBack: () {}, trailing: const Text('Akcja', style: TextStyle(color: AppColors.textOnAccent))),
          const SizedBox(height: 8),
          TopNavigation(title: 'Mój plan', trailing: AppTextButton(label: 'Wyczyść plan', type: AppTextButtonType.secondary)),

          _Section(title: 'Bottom Drawer'),
          BottomDrawer(
            title: 'Dodaj produkt',
            child: AppTextButton(label: 'Zatwierdź', type: AppTextButtonType.primary),
          ),

          _Section(title: 'Meal Type Cell'),
          _Row(label: 'Śniadanie', expand: false, child: MealTypeCell(label: 'Śniadanie')),
          _Row(label: 'Kolacja',   expand: false, child: MealTypeCell(label: 'Kolacja')),

          _Section(title: 'Day Selector'),
          _DaySelectorPreview(),

          _Section(title: 'Bottom Nav'),
          _BottomNavPreview(),

          _Section(title: 'Input Field'),
          _Row(label: 'Active', child: _InputDefault()),
          _Row(label: 'Default', child: _InputActive()),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Epilogue',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final Widget child;
  final bool expand;
  const _Row({required this.label, required this.child, this.expand = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.emptyStateText),
          ),
          if (expand) Expanded(child: child) else child,
        ],
      ),
    );
  }
}

// Stateful wrappers so inputs can show focus state ────────────────────────────

class _InputDefault extends StatelessWidget {
  const _InputDefault();

  @override
  Widget build(BuildContext context) {
    return const AppInputField(hintText: 'To jest nieaktywny input field');
  }
}

class _InputActive extends StatefulWidget {
  const _InputActive();

  @override
  State<_InputActive> createState() => _InputActiveState();
}

class _InputActiveState extends State<_InputActive> {
  final _controller = TextEditingController(text: 'To jest aktywny input field');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      controller: _controller,
      autofocus: false,
      hintText: 'To jest aktywny input field',
    );
  }
}

class _DaySelectorPreview extends StatefulWidget {
  const _DaySelectorPreview();
  @override
  State<_DaySelectorPreview> createState() => _DaySelectorPreviewState();
}

class _DaySelectorPreviewState extends State<_DaySelectorPreview> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DaySelector(
        selectedIndex: _index,
        onDaySelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomNavPreview extends StatefulWidget {
  const _BottomNavPreview();

  @override
  State<_BottomNavPreview> createState() => _BottomNavPreviewState();
}

class _BottomNavPreviewState extends State<_BottomNavPreview> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppBottomNav(
        selectedIndex: _index,
        onTabSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
