import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_text_button.dart';
import '../widgets/product_form.dart';
import '../widgets/shopping_row.dart';
import 'desktop_shell.dart';

class DesktopShoppingView extends StatelessWidget {
  final VoidCallback onGoToMenu;

  const DesktopShoppingView({super.key, required this.onGoToMenu});

  void _edit(BuildContext context, AppState state, ShoppingItem item) {
    final panel = DesktopPanelScope.of(context);
    panel.open(
      'Edytuj produkt',
      ProductForm(
        key: ValueKey('edit-${item.name}'),
        state: state,
        item: item,
        onDone: panel.close,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final all = state.shoppingItems;
    if (all.isEmpty) return _buildEmptyState();

    final items = [
      ...all.where((i) => !state.isBought(i.name)),
      ...all.where((i) => state.isBought(i.name)),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 32, 12, 32),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isBought = state.isBought(item.name);
        return ShoppingRow(
          name: item.name,
          quantity: ProductForm.formatQuantity(item.quantity, item.unit),
          category: item.category,
          isBought: isBought,
          onToggle: () => state.toggleBought(item.name),
          onEdit: isBought ? null : () => _edit(context, state, item),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }
}
