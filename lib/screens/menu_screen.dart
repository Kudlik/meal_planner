import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/top_navigation.dart';
import '../widgets/day_selector.dart';
import '../widgets/meal_type_cell.dart';
import '../widgets/meal_card.dart';
import '../widgets/bottom_drawer.dart';
import '../widgets/shopping_row.dart';
import 'meal_picker_screen.dart';

// ── Meal type definitions ─────────────────────────────────────────────────────
// ($1 = rawMealType used as data key, $2 = display label in accusative case)
const _mealRows = [
  ('Śniadanie', 'śniadanie'),
  ('Deser',     'deser'),
  ('Lunch',     'obiad'),   // rawMealType key stays 'Lunch', display is Polish accusative
  ('Kolacja',   'kolację'),
];

const _dayKeys = ['1-2', '3-4', '5-6', '7-8'];

// ── Drawer helpers ────────────────────────────────────────────────────────────

void _showPlanActionsDrawer(BuildContext context) {
  final appState = context.read<AppState>();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.backdrop,
    isScrollControlled: true,
    builder: (ctx) => BottomDrawer(
      title: 'Opcje planu',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShoppingRow(
            name: 'Podziel się planem',
            variant: ShoppingRowVariant.action,
            leadingIcon: 'assets/icons/Share.svg',
            onTap: () async {
              Navigator.pop(ctx);
              await appState.exportPlan();
            },
          ),
          ShoppingRow(
            name: 'Załaduj plan z pliku',
            variant: ShoppingRowVariant.action,
            leadingIcon: 'assets/icons/Upload.svg',
            onTap: () async {
              Navigator.pop(ctx);
              final error = await appState.importPlan();
              if (error != null && error.isNotEmpty && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}

void _showMealActionsDrawer(BuildContext context, String dayKey, String rawMealType) {
  final appState = context.read<AppState>();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.backdrop,
    isScrollControlled: true,
    builder: (ctx) => BottomDrawer(
      title: 'Opcje posiłku:',
      child: ShoppingRow(
        name: 'Usuń posiłek z menu',
        variant: ShoppingRowVariant.action,
        leadingIcon: 'assets/icons/Trash.svg',
        onTap: () {
          Navigator.pop(ctx);
          appState.removeFromSlot(dayKey, rawMealType);
        },
      ),
    ),
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedDay = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedDay);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToDay(int index) {
    setState(() => _selectedDay = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopNavigation(
              title: 'Mój plan',
              leading: GestureDetector(
                onTap: () => _showPlanActionsDrawer(context),
                child: SvgPicture.asset(
                  'assets/icons/HamburgerMenu.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(AppColors.textOnAccent, BlendMode.srcIn),
                ),
              ),
              trailing: GestureDetector(
                onTap: () => context.read<AppState>().clearPlan(),
                child: Text('Wyczyść plan', style: AppTextStyles.navLabel),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: DaySelector(
                  selectedIndex: _selectedDay,
                  onDaySelected: _goToDay,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sticky meal type labels
                    Column(
                      children: [
                        for (final row in _mealRows)
                          Expanded(child: MealTypeCell(label: row.$1)),
                      ],
                    ),
                    // Swipeable meal cards
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _selectedDay = i),
                        itemCount: _dayKeys.length,
                        itemBuilder: (context, index) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final row in _mealRows)
                              Expanded(
                                child: _MealCardSlot(
                                  rawMealType: row.$1,
                                  displayLabel: row.$2,
                                  dayKey: _dayKeys[index],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Meal card slot (card only — label column is sticky outside PageView) ──────

class _MealCardSlot extends StatelessWidget {
  final String rawMealType;
  final String displayLabel;
  final String dayKey;

  const _MealCardSlot({
    required this.rawMealType,
    required this.displayLabel,
    required this.dayKey,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final mealName = state.slotFor(dayKey, rawMealType)?.mealName;
    final meal = mealName != null ? state.mealInfo(mealName) : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(45, 12, 75, 12),
      child: MealCard(
        mealName: mealName,
        source: meal?.source,
        page: meal?.page,
        label: 'Dodaj\n$displayLabel',
        onTap: mealName == null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealPickerScreen(
                      dayKey: dayKey,
                      rawMealType: rawMealType,
                      displayMealType: displayLabel,
                    ),
                  ),
                )
            : () => _showMealActionsDrawer(context, dayKey, rawMealType),
      ),
    );
  }
}
