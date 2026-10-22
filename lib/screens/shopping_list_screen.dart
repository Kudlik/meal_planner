import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/top_navigation.dart';
import '../widgets/shopping_row.dart';
import '../widgets/bottom_drawer.dart';
import '../widgets/app_text_button.dart';
import '../widgets/product_form.dart';

class ShoppingListScreen extends StatelessWidget {
  final VoidCallback onGoToMenu;
  const ShoppingListScreen({super.key, required this.onGoToMenu});

  void _showAddDrawer(BuildContext context, AppState state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.backdrop,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: BottomDrawer(
          title: 'Dodaj produkt',
          child: ProductForm(state: state, onDone: () => Navigator.pop(ctx)),
        ),
      ),
    );
  }

  void _showEditDrawer(BuildContext context, AppState state, ShoppingItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.backdrop,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: BottomDrawer(
          title: 'Edytuj produkt',
          child: ProductForm(state: state, item: item, onDone: () => Navigator.pop(ctx)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopNavigation(
              title: 'Lista zakupów',
              trailing: GestureDetector(
                onTap: () => _showAddDrawer(context, state),
                child: Text('Dodaj produkt', style: AppTextStyles.navLabel),
              ),
            ),
            if (state.isShoppingListEmpty)
              Expanded(child: _buildEmptyState(context))
            else
              Expanded(child: _buildList(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lista zakupów jest pusta. Ułóż menu aby wiedzieć co musisz kupić',
              style: AppTextStyles.emptyStateText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppTextButton(
              label: 'Przejdź do menu',
              type: AppTextButtonType.primary,
              onPressed: onGoToMenu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, AppState state) {
    final all = state.shoppingItems;
    final items = [
      ...all.where((i) => !state.isBought(i.name)),
      ...all.where((i) => state.isBought(i.name)),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isBought = state.isBought(item.name);
        return ShoppingRow(
          name: item.name,
          quantity: _formatQty(item.quantity, item.unit),
          category: item.category,
          isBought: isBought,
          onToggle: () => state.toggleBought(item.name),
          onEdit: isBought
              ? null
              : () => _showEditDrawer(context, state, item),
        );
      },
    );
  }

  static String _formatQty(double qty, String unit) {
    if (qty == 0) return unit;
    final s = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);
    return unit.isEmpty ? s : '$s $unit';
  }
}
