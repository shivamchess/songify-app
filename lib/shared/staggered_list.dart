import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps a list of widgets in staggered entrance animations.
/// Each item cascades in with a bounce, delayed by [staggerMs] per item.
///
/// Usage:
/// ```dart
/// StaggeredList(
///   children: tracks.map((t) => TrackTile(track: t)).toList(),
/// )
/// ```
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.staggerMs = 60,
    this.initialOffsetY = 40.0,
  });

  final List<Widget> children;

  /// Delay between each item's animation start (milliseconds)
  final int staggerMs;

  /// How far below the final position items start (pixels)
  final double initialOffsetY;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final delay = Duration(milliseconds: index * staggerMs);

        return child
            .animate(delay: delay)
            .slideY(
              begin: initialOffsetY / 100,
              end: 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
            )
            .fadeIn(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
      }).toList(),
    );
  }
}

