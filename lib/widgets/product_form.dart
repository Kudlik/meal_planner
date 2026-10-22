import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'app_category_dropdown.dart';
import 'app_input_field.dart';
import 'app_text_button.dart';
import 'category_badge.dart';

/// Add / edit form for shopping list products. Shared by the mobile bottom
/// sheet and the desktop side panel; [onDone] closes whichever one hosts it.
class ProductForm extends StatefulWidget {
  final AppState state;
  final ShoppingItem? item; // null = add mode
  final VoidCallback onDone;

  const ProductForm({
    super.key,
    required this.state,
    required this.onDone,
    this.item,
  });

  /// "2kg", "350g", "4" — quantity with its unit, no separating space.
  static String formatQuantity(double qty, String unit) {
    if (qty == 0) return unit;
    final s = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);
    return unit.isEmpty ? s : '$s$unit';
  }

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  String? _category;

  bool get _isEditing => widget.item != null;
  bool get _isManual  => widget.item?.isManual ?? true;
  bool get _canConfirm => _isEditing || _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _qtyCtrl  = TextEditingController(
      text: item != null ? ProductForm.formatQuantity(item.quantity, item.unit) : '',
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
    widget.onDone();
  }

  void _submitFromKeyboard(String _) {
    if (_canConfirm) _confirm();
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
          onSubmitted: _submitFromKeyboard,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppInputField(
                controller: _qtyCtrl,
                hintText: 'Ilość (opcjonalnie)',
                onSubmitted: _submitFromKeyboard,
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
            onPressed: _canConfirm ? _confirm : null,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
