import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/playlist.dart';

/// Full-width header with large cover art, gradient fade, and metadata.
class PlaylistHeroHeader extends StatelessWidget {
  const PlaylistHeroHeader({super.key, required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        // ── Cover art (full width)
        SizedBox(
          width: size.width,
          height: size.width * 0.85,
          child: playlist.coverUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: playlist.coverUrl,
                  fit: BoxFit.cover,
                )
              : Container(color: AppColors.surfaceElevated),
        ),

        // ── Bottom gradient fade
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: size.width * 0.5,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.background],
              ),
            ),
          ),
        ),

        // ── Back button
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 12,
          child: _BackButton(),
        ),

        // ── Metadata overlay
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              if (playlist.description.isNotEmpty) ...
              [
                const SizedBox(height: 4),
                Text(
                  playlist.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '${playlist.totalTracks} tracks · by ${playlist.ownerName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
      ),
    );
  }
}
