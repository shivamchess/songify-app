import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Base elastic icon button used across the app.
/// All secondary icon controls derive from this.
/// Uses Curves.elasticOut on release for the "rubber" feel.
class JuicyIconButton extends StatefulWidget {
  const JuicyIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 24,
    this.padding = 12,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double padding;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  @override
  State<JuicyIconButton> createState() => _JuicyIconButtonState();
}

class _JuicyIconButtonState extends State<JuicyIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.78)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.78, end: 1.0)
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

  void _onTap() {
    _c.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.all(widget.padding),
          decoration: widget.backgroundColor != null
              ? BoxDecoration(
                  color: widget.backgroundColor,
                  shape: BoxShape.circle,
                )
              : null,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color ?? AppColors.iconDefault,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

