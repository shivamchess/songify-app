import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

/// The crown jewel of the Songify animation system.
///
/// A Play/Pause toggle button with a satisfying elastic squash-and-stretch
/// effect on every press. Uses [Curves.elasticOut] so the icon snaps back
/// like a rubber disc being flicked.
///
/// Animation breakdown:
///   1. On tap-down  → scale to 0.82 (squash) in 80ms with ease-in
///   2. On tap-up    → scale to 1.15 (overshoot) then settle at 1.0
///      via [Curves.elasticOut] over 600ms
///   3. Icon morphs between play ▶ and pause ⏸ with a crossfade + scale
class BouncyPlayPauseButton extends StatefulWidget {
  const BouncyPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
    this.size = 72.0,
    this.iconSize = 32.0,
    this.backgroundColor,
    this.iconColor,
  });

  final bool isPlaying;
  final VoidCallback onTap;

  /// Diameter of the circular button surface
  final double size;

  /// Size of the play/pause icon glyph
  final double iconSize;

  final Color? backgroundColor;
  final Color? iconColor;

  @override
  State<BouncyPlayPauseButton> createState() => _BouncyPlayPauseButtonState();
}

class _BouncyPlayPauseButtonState extends State<BouncyPlayPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Squash on press: 1.0 → 0.82 (first 13% of curve)
    // Elastic overshoot on release: 0.82 → 1.0 with bounce
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.82)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 13,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.82, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 87,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _controller.forward(from: 0.0);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.accent;
    final iconClr = widget.iconColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            // Glowing shadow that pulses when playing
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(widget.isPlaying ? 0.55 : 0.25),
                blurRadius: widget.isPlaying ? 28 : 12,
                spreadRadius: widget.isPlaying ? 4 : 1,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey<bool>(widget.isPlaying),
              size: widget.iconSize,
              color: iconClr,
            ),
          ),
        ),
      ),
    );
  }
}

