import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MealTypeCell extends StatelessWidget {
  final String label;

  const MealTypeCell({super.key, required this.label});

  static const _style = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 12 / 11,
    letterSpacing: 0.5,
    color: AppColors.accentSurface, // #F7F0E2
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: label.characters
              .map((char) => Text(char, style: _style, textAlign: TextAlign.center))
              .toList(),
        ),
      ),
    );
  }
}
