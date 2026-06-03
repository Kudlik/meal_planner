import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/category_badge.dart';

class ShoppingListScreen extends StatefulWidget {
  final VoidCallback onGoToMenu;
  const ShoppingListScreen({super.key, required this.onGoToMenu});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {

  void _showProductSheet(BuildContext context, AppState state, {ShoppingItem? item}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ProductSheet(state: state, item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isEmpty = state.isShoppingListEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isEmpty ? _buildEmptyState() : _buildList(context, state),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: widget.onGoToMenu,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Dodaj przepis', style: AppTextStyles.buttonLabel),
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
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () => _showProductSheet(context, state),
              icon: const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
              label: const Text(
                'Dodaj produkt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final item = items[index];
              final isBought = state.isBought(item.name);
              return _ShoppingRow(
                item: item,
                isBought: isBought,
                onToggle: () => state.toggleBought(item.name),
                onEdit: isBought
                    ? null
                    : () => _showProductSheet(context, state, item: item),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Bottom sheet for add / edit ──────────────────────────────────────────────

class _ProductSheet extends StatefulWidget {
  final AppState state;
  final ShoppingItem? item; // null = add mode

  const _ProductSheet({required this.state, this.item});

  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  String? _category;

  bool get _isEditing => widget.item != null;
  bool get _isManual => widget.item?.isManual ?? true;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _qtyController = TextEditingController(
      text: item != null ? _formatQty(item.quantity, item.unit) : '',
    );
    _category = item?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  enabled: _isManual,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Nazwa produktu',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtyController,
                        decoration: InputDecoration(
                          hintText: 'Ilość (opcjonalnie)',
                          hintStyle: const TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CategoryDropdown(
                      value: _category,
                      onChanged: _isManual
                          ? (v) => setState(() => _category = v)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.border,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _nameController.text.trim().isNotEmpty
                            ? () {
                                final qtyText = _qtyController.text.trim();
                                if (_isEditing) {
                                  if (_isManual) {
                                    widget.state.updateManualItem(
                                      widget.item!.name,
                                      _nameController.text.trim(),
                                      qtyText,
                                      _category,
                                    );
                                  } else {
                                    final qty = double.tryParse(
                                      qtyText.replaceAll(RegExp(r'[^0-9.]'), ''),
                                    ) ?? 0.0;
                                    final unit = qtyText.replaceAll(RegExp(r'[0-9. ]'), '').trim();
                                    widget.state.updateItemQuantity(
                                      widget.item!.name, qty, unit,
                                    );
                                  }
                                } else {
                                  widget.state.addManualItem(
                                    _nameController.text.trim(),
                                    qtyText,
                                    _category,
                                  );
                                }
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text('Zatwierdź', style: AppTextStyles.buttonLabel),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatQty(double qty, String unit) {
    if (qty == 0) return unit;
    final qtyStr = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);
    return unit.isEmpty ? qtyStr : '$qtyStr$unit';
  }
}

// ── Shopping row ─────────────────────────────────────────────────────────────

class _ShoppingRow extends StatelessWidget {
  final ShoppingItem item;
  final bool isBought;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  const _ShoppingRow({
    required this.item,
    required this.isBought,
    required this.onToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isBought ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isBought ? AppColors.primary : Colors.transparent,
              ),
              child: isBought
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: isBought
                      ? AppTextStyles.listItemNameStruck
                      : AppTextStyles.listItemName,
                ),
                if (item.quantity > 0 || item.unit.isNotEmpty)
                  Text(_formatQty(item.quantity, item.unit),
                      style: AppTextStyles.listItemQuantity),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!item.isManual || item.category != null)
            CategoryBadge(category: item.category, disabled: isBought),
          if (!isBought && onEdit != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatQty(double qty, String unit) {
    if (qty == 0) return unit;
    final qtyStr = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);
    return unit.isEmpty ? qtyStr : '$qtyStr $unit';
  }
}

// ── Category dropdown ─────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  static const _categories = [
    'owoce', 'warzywa', 'konserwowe', 'pieczywo', 'tłuszcze',
    'słodycze', 'nabiał', 'mięso', 'sypkie', 'mrożonki', 'higiena',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isDense: true,
          hint: const Text(
            'Kategoria',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          items: _categories
              .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: CategoryBadge(category: cat),
                  ))
              .toList(),
          selectedItemBuilder: (_) => _categories
              .map((cat) => Center(child: CategoryBadge(category: cat)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
