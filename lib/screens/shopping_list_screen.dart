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
  String? _editingItemName;
  final _editController = TextEditingController();

  bool _isAdding = false;
  final _addNameController = TextEditingController();
  final _addQtyController = TextEditingController();
  String? _addCategory;

  final Set<String> _boughtItems = {};

  @override
  void dispose() {
    _editController.dispose();
    _addNameController.dispose();
    _addQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isEmpty = state.isShoppingListEmpty;
    final isBlurred = _editingItemName != null || _isAdding;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isEmpty ? _buildEmptyState() : _buildList(state, isBlurred),
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

  Widget _buildList(AppState state, bool isBlurred) {
    final items = state.shoppingItems;
    return Stack(
      children: [
        Column(
          children: [
            const Divider(height: 1, color: AppColors.border),
            // "Dodaj produkt" button row
            AnimatedOpacity(
              opacity: isBlurred ? 0.15 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: IgnorePointer(
                ignoring: isBlurred,
                child: Padding(
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
                      onPressed: () => setState(() {
                        _isAdding = true;
                        _editingItemName = null;
                      }),
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
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isBought = _boughtItems.contains(item.name);
                  final isEditing = _editingItemName == item.name;
                  final dimmed = isBlurred && !isEditing;
                  return AnimatedOpacity(
                    opacity: dimmed ? 0.15 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: IgnorePointer(
                      ignoring: dimmed,
                      child: _ShoppingRow(
                        item: item,
                        isBought: isBought,
                        isEditing: isEditing,
                        editController: isEditing ? _editController : null,
                        onToggle: () => setState(() {
                          if (isBought) {
                            _boughtItems.remove(item.name);
                          } else {
                            _boughtItems.add(item.name);
                          }
                        }),
                        onEdit: isBought
                            ? null
                            : () {
                                _editController.text = _formatQty(item.quantity, item.unit);
                                setState(() => _editingItemName = item.name);
                              },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // Edit confirm button
        if (_editingItemName != null)
          _buildEditOverlay(state),
        // Add product overlay
        if (_isAdding)
          _buildAddOverlay(state),
      ],
    );
  }

  Widget _buildEditOverlay(AppState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
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
                final text = _editController.text.trim();
                final qty = double.tryParse(
                      text.replaceAll(RegExp(r'[^0-9.]'), ''),
                    ) ??
                    0.0;
                final unit = text.replaceAll(RegExp(r'[0-9. ]'), '').trim();
                state.updateItemQuantity(_editingItemName!, qty, unit);
                setState(() => _editingItemName = null);
              },
              child: const Text('Zatwierdź', style: AppTextStyles.buttonLabel),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddOverlay(AppState state) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // absorb taps outside
        child: Column(
          children: [
            const Spacer(),
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addNameController,
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addQtyController,
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
                        value: _addCategory,
                        onChanged: (v) => setState(() => _addCategory = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: _addNameController.text.trim().isNotEmpty
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                state.addManualItem(
                                  _addNameController.text.trim(),
                                  _addQtyController.text.trim(),
                                  _addCategory,
                                );
                                _addNameController.clear();
                                _addQtyController.clear();
                                setState(() {
                                  _isAdding = false;
                                  _addCategory = null;
                                });
                              },
                              child: const Text('Zatwierdź', style: AppTextStyles.buttonLabel),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                _addNameController.clear();
                                _addQtyController.clear();
                                setState(() {
                                  _isAdding = false;
                                  _addCategory = null;
                                });
                              },
                              child: const Text(
                                'Anuluj',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatQty(double qty, String unit) {
    if (qty == 0) return '';
    final qtyStr = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);
    return unit.isEmpty ? qtyStr : '$qtyStr$unit';
  }
}

class _ShoppingRow extends StatelessWidget {
  final ShoppingItem item;
  final bool isBought;
  final bool isEditing;
  final TextEditingController? editController;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  const _ShoppingRow({
    required this.item,
    required this.isBought,
    required this.isEditing,
    this.editController,
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
                if (isEditing && editController != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: editController,
                        autofocus: true,
                        style: AppTextStyles.listItemQuantity,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                      ),
                    ),
                  )
                else if (item.quantity > 0 || item.unit.isNotEmpty)
                  Text(_formatQty(item.quantity, item.unit),
                      style: AppTextStyles.listItemQuantity),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!item.isManual || item.category != null)
            CategoryBadge(category: item.category, disabled: isBought),
          if (!isBought && !isEditing && onEdit != null) ...[
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

class _CategoryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  static const _categories = [
    'owoce', 'warzywa', 'konserwowe', 'pieczywo', 'tłuszcze',
    'słodycze', 'nabiał', 'mięso', 'sypkie', 'mrożonki',
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
