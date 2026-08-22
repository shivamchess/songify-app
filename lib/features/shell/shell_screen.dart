import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/mini_player_strip.dart';
import '../../core/theme/app_colors.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _index = 0;
  static const _routes = ['/home', '/search', '/library', '/profile'];
  static const _labels = ['Home', 'Search', 'Library', 'Profile'];
  static const _icons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.library_music_rounded,
    Icons.person_rounded,
  ];
  static const _activeIcons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.library_music_rounded,
    Icons.person_rounded,
  ];

  void _tap(int i) {
    if (_index == i) return;
    setState(() => _index = i);
    context.go(_routes[i]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(child: widget.child),
          const MiniPlayerStrip(),
        ],
      ),
      bottomNavigationBar: _JuicyBottomNav(
        currentIndex: _index,
        onTap: _tap,
        labels: _labels,
        icons: _icons,
        activeIcons: _activeIcons,
      ),
    );
  }
}

// ── Custom animated bottom nav ─────────────────────────────────────────────

class _JuicyBottomNav extends StatelessWidget {
  const _JuicyBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.labels,
    required this.icons,
    required this.activeIcons,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> icons;
  final List<IconData> activeIcons;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(labels.length, (i) => Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: currentIndex == i
                            ? ShaderMask(
                                key: const ValueKey('active'),
                                shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                                child: Icon(activeIcons[i], size: 26, color: Colors.white),
                              )
                            : Icon(icons[i], size: 24, color: AppColors.iconDefault, key: const ValueKey('inactive')),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: currentIndex == i ? FontWeight.w700 : FontWeight.w400,
                          color: currentIndex == i ? AppColors.accentSoft : AppColors.iconDefault,
                        ),
                        child: Text(labels[i]),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: currentIndex == i ? 20 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: currentIndex == i ? AppColors.primaryGradient : null,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }
}
