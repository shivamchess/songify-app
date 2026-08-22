import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../state/player/player_state_notifier.dart';
import '../../state/favorites/favorites_notifier.dart';
import '../now_playing/now_playing_panel.dart';

class MiniPlayerStrip extends ConsumerWidget {
  const MiniPlayerStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerStateProvider);
    final track = state.currentTrack;
    if (track.id.isEmpty) return const SizedBox.shrink();

    final isFav = ref.watch(favoritesProvider).contains(track.id);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const NowPlayingPanel(),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              AppColors.surfaceElevated,
              AppColors.accent.withOpacity(0.15),
            ],
          ),
          border: Border.all(color: AppColors.accent.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(color: AppColors.accent.withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            // Album art
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
              child: track.albumArtSmall.isNotEmpty
                  ? CachedNetworkImage(imageUrl: track.albumArtSmall, width: 64, height: 64, fit: BoxFit.cover)
                  : Container(width: 64, height: 64, color: AppColors.surface,
                      child: const Icon(Icons.music_note_rounded, color: AppColors.accent)),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(track.artist,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )),
            // Fav
            IconButton(
              onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(track.id),
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.pink : AppColors.iconDefault, size: 20),
              splashFactory: NoSplash.splashFactory,
            ),
            // Prev
            IconButton(
              onPressed: () => ref.read(playerStateNotifierProvider.notifier).previous(),
              icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 24),
              splashFactory: NoSplash.splashFactory,
            ),
            // Play/Pause
            GestureDetector(
              onTap: () => ref.read(playerStateNotifierProvider.notifier).togglePlayPause(),
              child: Container(
                width: 38, height: 38,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 12)],
                ),
                child: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
            // Next
            IconButton(
              onPressed: () => ref.read(playerStateNotifierProvider.notifier).next(),
              icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 24),
              splashFactory: NoSplash.splashFactory,
            ),
          ],
        ),
      ),
    );
  }
}
