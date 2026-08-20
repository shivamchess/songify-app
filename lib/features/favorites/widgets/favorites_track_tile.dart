import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A track row in the favorites screen with swipe-to-remove.
class FavoritesTrackTile extends StatelessWidget {
  const FavoritesTrackTile({
    super.key,
    required this.trackId,
    required this.onRemove,
  });

  final String trackId;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(trackId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error.withValues(alpha: 0.15),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 26,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceElevated,
          child: Icon(
            Icons.favorite_rounded,
            color: AppColors.error,
            size: 20,
          ),
        ),
        title: Text(
          trackId,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text(
          'Swipe left to remove',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.iconDefault,
        ),
      ),
    );
  }
}
