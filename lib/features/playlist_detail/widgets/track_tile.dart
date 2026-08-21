import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../models/track.dart';

/// Single track row in the playlist detail screen.
/// The stagger animation is applied externally by [StaggeredList].
class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.index,
    required this.onTap,
  });

  final Track track;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.accentGlow,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // ── Index or thumbnail
            SizedBox(
              width: 44,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: track.albumArtSmall.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: track.albumArtSmall,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: AppColors.surfaceElevated,
                        child: Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    track.artist,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Duration
            Text(
              Duration(milliseconds: track.durationMs).mmSs,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

