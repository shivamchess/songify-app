import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

/// Custom animated BottomNavigationBar matching the dark neon mockup.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.height = 72,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double height;

  static const _items = [
    _NavItem(icon: Icons.home_filled, label: 'Home'),
    _NavItem(icon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.library_music_rounded, label: 'Library'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height + MediaQuery.paddingOf(context).bottom,
      decoration: const BoxDecoration(
        color: AppColors.background, // Match the deep black
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: _items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final isSelected = i == selectedIndex;
            return Expanded(
              child: _NavButton(
                item: item,
                isSelected: isSelected,
                onTap: () => onTap(i),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.75)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.75, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 85,
      ),
    ]).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_NavButton old) {
    super.didUpdateWidget(old);
    if (!old.isSelected && widget.isSelected) {
      _c.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                widget.item.icon,
                key: ValueKey(widget.isSelected),
                size: 26,
                color: widget.isSelected
                    ? AppColors.accent
                    : AppColors.iconDefault,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: widget.isSelected
                    ? AppColors.accent
                    : AppColors.iconDefault,
              ),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}

