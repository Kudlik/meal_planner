import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DaySelector extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  static const labels = ['1-2', '3-4', '5-6', '7-8'];

  const DaySelector({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Tween<double> _tween;
  late Animation<double> _position;

  // Button: ~32px wide × 28px tall (6px padding + 16px text + 6px padding)
  static const double _btnWidth  = 32.0;
  static const double _btnHeight = 28.0;
  static const double _gap       = 24.0;
  static const double _step      = _btnWidth + _gap; // 56px per tab

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tween    = Tween(begin: widget.selectedIndex.toDouble(), end: widget.selectedIndex.toDouble());
    _position = _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(DaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _tween    = Tween(begin: _position.value, end: widget.selectedIndex.toDouble());
      _position = _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.textOnCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedBuilder(
        animation: _position,
        builder: (context, _) {
          return Stack(
            children: [
              // Tap targets (bottom layer)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onDaySelected(i),
                      child: const SizedBox(width: _btnWidth, height: _btnHeight),
                    ),
                  ],
                ],
              ),
              // Sliding pill
              Positioned(
                left: _position.value * _step,
                top: 0,
                child: Container(
                  width: _btnWidth,
                  height: _btnHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Labels (pointer events fall through)
              IgnorePointer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      SizedBox(
                        width: _btnWidth,
                        height: _btnHeight,
                        child: Center(
                          child: Text(
                            DaySelector.labels[i],
                            style: TextStyle(
                              fontFamily: 'Epilogue',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 16 / 12,
                              letterSpacing: 0.4,
                              // Cross-fade label color as pill passes over
                              color: Color.lerp(
                                AppColors.textOnCard,
                                AppColors.surface,
                                (_position.value - i).abs().clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
