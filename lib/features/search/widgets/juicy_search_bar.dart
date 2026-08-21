import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated search bar matching the Juicy aesthetic.
/// Pill-shaped with a deep purple neon glow when focused.
class JuicySearchBar extends StatefulWidget {
  const JuicySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<JuicySearchBar> createState() => _JuicySearchBarState();
}

class _JuicySearchBarState extends State<JuicySearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusAnim;
  late final Animation<double> _glowAnim;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowAnim = CurvedAnimation(parent: _focusAnim, curve: Curves.fastOutSlowIn);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusAnim.forward();
      } else {
        _focusAnim.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusAnim.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32), // Pill shape like mockup
            color: AppColors.surfaceElevated,
            border: Border.all(
              color: Color.lerp(
                Colors.transparent, 
                AppColors.accent, 
                _glowAnim.value
              )!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(_glowAnim.value * 0.2),
                blurRadius: 16 * _glowAnim.value,
                spreadRadius: 2 * _glowAnim.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search tracks, artists...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.search_rounded, color: AppColors.iconDefault),
          ),
          suffixIcon: ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: widget.onClear,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.close_rounded, color: AppColors.iconDefault),
                ),
              );
            },
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}


