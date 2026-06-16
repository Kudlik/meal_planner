import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _c1; // "Chyba czas na..."
  late final AnimationController _c2; // icon
  late final AnimationController _c3; // "Jedzonko!"

  // Curved progress 0→1 for each step, used with screen-width translate
  late final Animation<double> _subtitleProgress;
  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _titleProgress;

  bool _animsDone = false;

  @override
  void initState() {
    super.initState();

    _c1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _c2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _c3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _subtitleProgress = CurvedAnimation(parent: _c1, curve: Curves.easeOut);
    _iconFade         = CurvedAnimation(parent: _c2, curve: Curves.easeIn);
    _iconScale        = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _c2, curve: Curves.easeOut));
    _titleProgress    = CurvedAnimation(parent: _c3, curve: Curves.easeOut);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _c1.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _c2.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _c3.forward();

    if (!mounted) return;
    _animsDone = true;

    final appState = context.read<AppState>();
    if (appState.isLoaded) {
      widget.onComplete();
    } else {
      appState.addListener(_onStateChanged);
    }
  }

  void _onStateChanged() {
    if (!mounted) return;
    final appState = context.read<AppState>();
    if (appState.isLoaded && _animsDone) {
      appState.removeListener(_onStateChanged);
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    context.read<AppState>().removeListener(_onStateChanged);
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // "Chyba czas na..." — slides in from the LEFT
            AnimatedBuilder(
              animation: _subtitleProgress,
              builder: (_, child) => Transform.translate(
                offset: Offset(-(1.0 - _subtitleProgress.value) * screenWidth, 0),
                child: child,
              ),
              child: const Text('Chyba czas na...', style: AppTextStyles.displaySubtitle),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _iconFade,
              child: ScaleTransition(
                scale: _iconScale,
                child: SvgPicture.asset(
                  'assets/icons/MealReadyBig.svg',
                  width: 80,
                  height: 80,
                  colorFilter: const ColorFilter.mode(AppColors.accentBright, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // "Jedzonko!" — slides in from the RIGHT
            AnimatedBuilder(
              animation: _titleProgress,
              builder: (_, child) => Transform.translate(
                offset: Offset((1.0 - _titleProgress.value) * screenWidth, 0),
                child: child,
              ),
              child: const Text('Jedzonko!', style: AppTextStyles.displayHero),
            ),
          ],
        ),
      ),
    );
  }
}
