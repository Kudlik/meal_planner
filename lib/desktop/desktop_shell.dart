import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/product_form.dart';
import 'desktop_menu_view.dart';
import 'desktop_shopping_view.dart';

/// Window width from which the app switches from the phone layout to the
/// desktop one.
const double kDesktopBreakpoint = 900;

// Design reference: 1920px wide window → 160px side gutters, 522px side panel.
const double _kDesignWidth = 1920;
const double _kDesignGutter = 160;
const double _kDesignPanelWidth = 522;

/// Lets the desktop views open / close the right-hand side panel that
/// replaces the phone's bottom sheets.
class DesktopPanelScope extends InheritedWidget {
  /// Shows [child] in the side panel. Set [scrollable] to false when the child
  /// manages its own scrolling (e.g. a long list with a pinned button).
  final void Function(String title, Widget child, {bool scrollable}) open;
  final VoidCallback close;

  const DesktopPanelScope({
    super.key,
    required this.open,
    required this.close,
    required super.child,
  });

  static DesktopPanelScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<DesktopPanelScope>();
    assert(scope != null, 'No DesktopPanelScope above this context');
    return scope!;
  }

  @override
  bool updateShouldNotify(DesktopPanelScope oldWidget) => false;
}

class DesktopShell extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const DesktopShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  String? _panelTitle;
  Widget? _panelChild;
  bool _panelScrollable = true;

  bool get _panelOpen => _panelChild != null;

  @override
  void initState() {
    super.initState();
    // A global handler (rather than a Shortcuts widget) so Escape works no
    // matter which widget — if any — currently holds keyboard focus.
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    if (_panelOpen &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _closePanel();
      return true;
    }
    return false;
  }

  void _openPanel(String title, Widget child, {bool scrollable = true}) =>
      setState(() {
        _panelTitle = title;
        _panelChild = child;
        _panelScrollable = scrollable;
      });

  void _closePanel() {
    if (!_panelOpen) return;
    setState(() {
      _panelTitle = null;
      _panelChild = null;
    });
  }

  void _selectTab(int index) {
    _closePanel();
    widget.onTabSelected(index);
  }

  void _openAddProduct() {
    final state = context.read<AppState>();
    _openPanel(
      'Dodaj produkt',
      ProductForm(
        key: const ValueKey('add-product'),
        state: state,
        onDone: _closePanel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / _kDesignWidth;
    final gutter = (_kDesignGutter * scale).clamp(32.0, _kDesignGutter);
    final panelWidth = (_kDesignPanelWidth * scale).clamp(360.0, _kDesignPanelWidth);
    final onShopping = widget.currentIndex == 1;

    return DesktopPanelScope(
      open: _openPanel,
      close: _closePanel,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _Header(
              currentIndex: widget.currentIndex,
              onTabSelected: _selectTab,
              trailing: onShopping
                  ? _HeaderTextButton(
                      label: 'Dodaj produkt',
                      onPressed: _openAddProduct,
                    )
                  : _HeaderTextButton(
                      label: 'Wyczyść plan',
                      onPressed: () => context.read<AppState>().clearPlan(),
                    ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: gutter,
                              right: _panelOpen ? 32 : gutter,
                            ),
                            child: IndexedStack(
                              index: widget.currentIndex,
                              children: [
                                const DesktopMenuView(),
                                DesktopShoppingView(onGoToMenu: () => _selectTab(0)),
                              ],
                            ),
                          ),
                        ),
                        if (_panelOpen)
                          Positioned.fill(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _closePanel,
                                child: const ColoredBox(color: AppColors.backdrop),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.centerLeft,
                    child: _panelOpen
                        ? _SidePanel(
                            width: panelWidth,
                            title: _panelTitle!,
                            scrollable: _panelScrollable,
                            child: _panelChild!,
                          )
                        : const SizedBox(width: 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget trailing;

  const _Header({
    required this.currentIndex,
    required this.onTabSelected,
    required this.trailing,
  });

  static const _titleStyle = TextStyle(
    fontFamily: 'GowunBatang',
    fontSize: 45,
    height: 52 / 45,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnAccent,
  );

  static const _tabs = ['Menu', 'Lista zakupów'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      color: AppColors.accentMid,
      child: Row(
        children: [
          const Text('Jedzonko', style: _titleStyle),
          const SizedBox(width: 16),
          for (var i = 0; i < _tabs.length; i++)
            _HeaderTab(
              label: _tabs[i],
              selected: i == currentIndex,
              onTap: () => onTabSelected(i),
            ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

class _HeaderTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HeaderTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _labelStyle = TextStyle(
    fontFamily: 'GowunBatang',
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnAccent,
  );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 180,
          child: Center(
            child: SizedBox(
              height: 48,
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: Center(child: Text(label, style: _labelStyle))),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.textOnAccent : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flat text button that sits on the cream header (cream-on-cream, as in the
/// design — only the label is visible).
class _HeaderTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _HeaderTextButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textOnAccent,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppTextStyles.buttonLabel.copyWith(color: AppColors.textOnAccent),
      ),
    );
  }
}

// ── Side panel ────────────────────────────────────────────────────────────────

class _SidePanel extends StatelessWidget {
  final double width;
  final String title;
  final bool scrollable;
  final Widget child;

  const _SidePanel({
    required this.width,
    required this.title,
    required this.scrollable,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppColors.textSecondary,
      padding: const EdgeInsets.fromLTRB(32, 36, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.accentBright),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 24),
          Expanded(
            child: scrollable ? SingleChildScrollView(child: child) : child,
          ),
        ],
      ),
    );
  }
}
