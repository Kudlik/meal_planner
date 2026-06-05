import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppInputField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool autofocus;
  final bool enabled;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AppInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.autofocus = false,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  static const _radius = BorderRadius.only(
    topLeft: Radius.circular(3),
    topRight: Radius.circular(3),
  );

  static const _textBase = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
    letterSpacing: 0.5,
  );

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      style: _textBase.copyWith(
        color: _isFocused ? AppColors.accent : AppColors.accentSurface,
      ),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: _textBase.copyWith(
          color: _isFocused ? AppColors.accent : AppColors.accentSurface,
        ),
        filled: true,
        fillColor: AppColors.textDark,
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentSurface, width: 1),
          borderRadius: _radius,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent, width: 1),
          borderRadius: _radius,
        ),
        disabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.disabled, width: 1),
          borderRadius: _radius,
        ),
      ),
    );
  }
}
