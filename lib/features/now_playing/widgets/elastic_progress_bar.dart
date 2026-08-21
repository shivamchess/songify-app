import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_formatter.dart';

/// A rubbery, elastic seek bar for the Now Playing screen.
///
/// The thumb uses a custom [SliderTheme] with a scaled-up active thumb
/// that snaps elastically when the user lifts their finger.
class ElasticProgressBar extends StatefulWidget {
  const ElasticProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<ElasticProgressBar> createState() => _ElasticProgressBarState();
}

class _ElasticProgressBarState extends State<ElasticProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _thumbController;
  late final Animation<double> _thumbScale;
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  void initState() {
    super.initState();
    _thumbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _thumbScale = Tween(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _thumbController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _thumbController.dispose();
    super.dispose();
  }

  double get _progress {
    if (widget.duration.inMilliseconds == 0) return 0;
    if (_isDragging) return _dragValue;
    return (widget.position.inMilliseconds / widget.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Seek slider ──────────────────────────────────────────────────
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3.5,
            thumbShape: _ElasticThumbShape(scaleAnimation: _thumbScale),
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.accent,
            overlayColor: AppColors.accentGlow,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: _progress,
            onChangeStart: (_) {
              _isDragging = true;
              // Scale up the thumb elastically on drag start
              _thumbController.forward(from: 0);
            },
            onChanged: (v) => setState(() => _dragValue = v),
            onChangeEnd: (v) {
              _isDragging = false;
              final ms = (v * widget.duration.inMilliseconds).round();
              widget.onSeek(Duration(milliseconds: ms));
              // Snap back
              _thumbController.reverse();
            },
          ),
        ),

        // ── Time labels ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.position.mmSs,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                widget.duration.mmSs,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// Custom thumb that scales up elastically when dragged.
class _ElasticThumbShape extends SliderComponentShape {
  const _ElasticThumbShape({required this.scaleAnimation});

  final Animation<double> scaleAnimation;
  static const double _thumbRadius = 7.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final scale = 1.0 + (activationAnimation.value * 0.6);
    final radius = _thumbRadius * scale;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = sliderTheme.thumbColor ?? AppColors.accent,
    );
  }
}

