import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../state/player/player_state_notifier.dart';

import '../now_playing/now_playing_panel.dart';

class MiniPlayerStrip extends ConsumerWidget {
  const MiniPlayerStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerStateProvider);
    final track = state.currentTrack;

    if (track.id.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: AppColors.background,
          builder: (context) => const NowPlayingPanel(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: track.albumArtSmall.isNotEmpty
                ? CachedNetworkImage(imageUrl: track.albumArtSmall, width: 40, height: 40, fit: BoxFit.cover)
                : Container(width: 40, height: 40, color: AppColors.surface, child: const Icon(Icons.music_note, color: AppColors.accent, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(track.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(playerStateNotifierProvider.notifier).previous(),
            icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
          GestureDetector(
            onTap: () => ref.read(playerStateNotifierProvider.notifier).togglePlayPause(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
              child: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 20),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(playerStateNotifierProvider.notifier).next(),
            icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
        ],
      ),
    );
  }
}
