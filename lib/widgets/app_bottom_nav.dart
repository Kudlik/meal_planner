import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;

  // Each button: 6px padding + 24px icon + 6px padding = 36px
  // Gap between buttons: 24px → slide distance = 36 + 24 = 60px
  static const double _btnSize = 36;
  static const double _gap = 24;
  static const double _slideDistance = _btnSize + _gap;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.selectedIndex.toDouble(),
    );
    _slide = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(AppBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      widget.selectedIndex == 1 ? _controller.forward() : _controller.reverse();
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
      width: 131,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: SizedBox(
          width: _btnSize * 2 + _gap, // 96px — exact content width
          height: _btnSize,
          child: AnimatedBuilder(
            animation: _slide,
            builder: (context, _) => Stack(
          children: [
            // Tap targets (bottom layer)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onTabSelected(0),
                  child: const SizedBox(width: _btnSize, height: _btnSize),
                ),
                const SizedBox(width: _gap),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onTabSelected(1),
                  child: const SizedBox(width: _btnSize, height: _btnSize),
                ),
              ],
            ),
            // Sliding pill
            Positioned(
              left: _slide.value * _slideDistance,
              top: 0,
              child: Container(
                width: _btnSize,
                height: _btnSize,
                decoration: BoxDecoration(
                  color: AppColors.accentBright,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Icons (on top, pointer events fall through to tap targets)
            IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon('assets/icons/Menu.svg', tabIndex: 0),
                  const SizedBox(width: _gap),
                  _buildIcon('assets/icons/Shopping.svg', tabIndex: 1),
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String asset, {required int tabIndex}) {
    // Lerp icon color: active = textLabel (#6E5D0E), inactive = accent (#DDC66E)
    final t = tabIndex == 0 ? _slide.value : 1.0 - _slide.value;
    final color = Color.lerp(AppColors.textLabel, AppColors.accent, t)!;

    return SizedBox(
      width: _btnSize,
      height: _btnSize,
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
