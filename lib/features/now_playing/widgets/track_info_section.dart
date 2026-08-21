import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/track.dart';
import '../../../state/favorites/favorites_notifier.dart';
import '../../../core/theme/app_colors.dart';

/// Displays track title, artist name, and an animated heart favorite toggle.
class TrackInfoSection extends ConsumerWidget {
  const TrackInfoSection({super.key, required this.track});
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(track.id);

    return Row(
      children: [
        // ── Track text ───────────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                track.artist,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ── Heart button ─────────────────────────────────────────────────
        _HeartButton(
          isFavorite: isFavorite,
          onTap: () => ref
              .read(favoritesProvider.notifier)
              .toggleFavorite(track.id),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _HeartButton extends StatefulWidget {
  const _HeartButton({required this.isFavorite, required this.onTap});
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton>
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
          tween: Tween(begin: 1.0, end: 0.6)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: 0.6, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 85),
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
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(widget.isFavorite),
            color: widget.isFavorite ? AppColors.error : AppColors.iconDefault,
            size: 28,
          ),
        ),
      ),
    );
  }
}

