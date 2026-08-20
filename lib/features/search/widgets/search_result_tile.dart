import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/track.dart';
import '../../../core/utils/duration_formatter.dart';

/// Single search result row.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.track,
    required this.onTap,
  });

  final Track track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: track.albumArtSmall.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: track.albumArtSmall,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              )
            : Container(
                width: 48,
                height: 48,
                color: AppColors.surfaceElevated,
                child: const Icon(Icons.music_note_rounded,
                    color: AppColors.iconDefault),
              ),
      ),
      title: Text(
        track.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        Duration(milliseconds: track.durationMs).mmSs,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
