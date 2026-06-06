import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
import 'screens/menu_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/component_gallery.dart';
import 'widgets/app_bottom_nav.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const MealPlannerApp(),
    ),
  );
}

class MealPlannerApp extends StatefulWidget {
  const MealPlannerApp({super.key});

  @override
  State<MealPlannerApp> createState() => _MealPlannerAppState();
}

class _MealPlannerAppState extends State<MealPlannerApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jedzonko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Epilogue',
      ),
      home: _splashDone
          ? const _RootScreen()
          : SplashScreen(onComplete: () => setState(() => _splashDone = true)),
    );
  }
}

class _RootScreen extends StatefulWidget {
  const _RootScreen();

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  int _currentIndex = 0;
  int _shoppingTapCount = 0;
  Timer? _tapResetTimer;

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == 1) {
      _shoppingTapCount++;
      _tapResetTimer?.cancel();
      _tapResetTimer = Timer(const Duration(seconds: 2), () {
        _shoppingTapCount = 0;
      });
      if (_shoppingTapCount >= 6) {
        _shoppingTapCount = 0;
        _tapResetTimer?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ComponentGallery()),
        );
        return;
      }
    } else {
      _shoppingTapCount = 0;
      _tapResetTimer?.cancel();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              const MenuScreen(),
              ShoppingListScreen(
                onGoToMenu: () => setState(() => _currentIndex = 0),
              ),
            ],
          ),
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(
              child: AppBottomNav(
                selectedIndex: _currentIndex,
                onTabSelected: _onTabSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
