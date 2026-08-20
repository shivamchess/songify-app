import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/playlist.dart';

/// A bouncy, tappable playlist card for the horizontal carousel.
/// Presses down on touch and bounces back with [Curves.elasticOut].
class PlaylistCard extends StatefulWidget {
  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    this.width = 160,
  });

  final Playlist playlist;
  final VoidCallback onTap;
  final double width;

  @override
  State<PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.93)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.93, end: 1.0)
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _c.forward(from: 0);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover art
              Container(
                width: widget.width,
                height: widget.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.surfaceElevated,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.playlist.coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.playlist.coverUrl,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.queue_music_rounded,
                          size: 48,
                          color: AppColors.iconDefault,
                        ),
                ),
              ),
              const SizedBox(height: 10),
              // ── Title
              Text(
                widget.playlist.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.playlist.ownerName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
