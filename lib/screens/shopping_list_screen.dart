import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/top_navigation.dart';
import '../widgets/shopping_row.dart';
import '../widgets/bottom_drawer.dart';
import '../widgets/app_input_field.dart';
import '../widgets/app_category_dropdown.dart';
import '../widgets/app_text_button.dart';
import '../widgets/category_badge.dart';

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
          child: _ProductForm(state: state),
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
          child: _ProductForm(state: state, item: item),
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

// ── Product form (used in both add and edit drawers) ──────────────────────────

class _ProductForm extends StatefulWidget {
  final AppState state;
  final ShoppingItem? item; // null = add mode

  const _ProductForm({required this.state, this.item});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  String? _category;

  bool get _isEditing => widget.item != null;
  bool get _isManual  => widget.item?.isManual ?? true;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _qtyCtrl  = TextEditingController(
      text: item != null ? _formatQty(item.quantity, item.unit) : '',
    );
    _category = item?.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty && !_isEditing) return;

    final qtyText = _qtyCtrl.text.trim();

    if (_isEditing) {
      if (_isManual) {
        widget.state.updateManualItem(widget.item!.name, name, qtyText, _category);
      } else {
        final qty  = double.tryParse(qtyText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final unit = qtyText.replaceAll(RegExp(r'[0-9. ]'), '').trim();
        widget.state.updateItemQuantity(widget.item!.name, qty, unit);
      }
    } else {
      widget.state.addManualItem(name, qtyText, _category);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInputField(
          controller: _nameCtrl,
          hintText: 'Nazwa produktu',
          enabled: _isManual,
          autofocus: !_isEditing,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppInputField(
                controller: _qtyCtrl,
                hintText: 'Ilość (opcjonalnie)',
              ),
            ),
            const SizedBox(width: 8),
            // Category: selectable when adding or editing a manual item,
            // read-only badge for recipe-derived items
            if (_isManual)
              AppCategoryDropdown(
                value: _category,
                onChanged: (v) => setState(() => _category = v),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: CategoryBadge(category: widget.item?.category),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: AppTextButton(
            label: 'Zatwierdź',
            type: AppTextButtonType.primary,
            onPressed: (_isEditing || _nameCtrl.text.trim().isNotEmpty)
                ? _confirm
                : null,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  static String _formatQty(double qty, String unit) {
    if (qty == 0) return unit;
    final s = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);
    return unit.isEmpty ? s : '$s$unit';
  }
}
