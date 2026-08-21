import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

/// Animated album artwork widget with smooth transitions between tracks.
///
/// Uses [AnimatedSwitcher] so that when [artUrl] changes:
///   - Old artwork scales down (0.9) and fades out
///   - New artwork bounces in from scale 0.7 ? 1.05 ? 1.0 (elasticOut)
///
/// The artwork sits inside a heavy shadow for depth.
class AlbumArtSwitcher extends StatelessWidget {
  const AlbumArtSwitcher({
    super.key,
    required this.artUrl,
    this.size = 300,
    this.borderRadius = 20,
  });

  final String artUrl;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        // Scale in: bouncy elastic for new art
        // Scale out: quick shrink for old art
        final isIncoming = child.key == ValueKey(artUrl);

        final scaleAnim = isIncoming
            ? Tween<double>(begin: 0.70, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              )
            : Tween<double>(begin: 1.0, end: 0.90).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeIn),
              );

        return ScaleTransition(
          scale: scaleAnim,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _ArtworkImage(
        key: ValueKey(artUrl),
        artUrl: artUrl,
        size: size,
        borderRadius: borderRadius,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ArtworkImage extends StatelessWidget {
  const _ArtworkImage({
    super.key,
    required this.artUrl,
    required this.size,
    required this.borderRadius,
  });

  final String artUrl;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: AppColors.surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: AppColors.accent.withOpacity(0.12),
            blurRadius: 60,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: artUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: artUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _ArtworkPlaceholder(),
                errorWidget: (_, __, ___) => const _ArtworkPlaceholder(),
              )
            : const _ArtworkPlaceholder(),
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceElevated,
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 64,
          color: AppColors.iconDefault,
        ),
      ),
    );
  }
}

