import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../state/player/player_state_notifier.dart';
import '../../now_playing/widgets/bouncy_play_pause_button.dart';

/// Slim mini player strip matching the mockup's neon styling.
class MiniPlayerStrip extends ConsumerWidget {
  const MiniPlayerStrip({super.key, required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final track = playerState.currentTrack;
    final isPlaying = playerState.isPlaying;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.15), 
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // ── Thumbnail (circular like mockup or slightly rounded)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.music_note_rounded,
                          size: 20,
                          color: AppColors.iconDefault,
                        ),
                      ),
              ),

              const SizedBox(width: 12),

              // ── Title + Artist ───────────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(height: 2),
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

              // ── Mockup shows previous, play, next buttons in mini player
              Icon(Icons.skip_previous_rounded, color: AppColors.iconDefault, size: 28),
              const SizedBox(width: 8),
              BouncyPlayPauseButton(
                isPlaying: isPlaying,
                onTap: () => ref
                    .read(playerStateNotifierProvider.notifier)
                    .togglePlayPause(),
                size: 44,
                iconSize: 22,
                backgroundColor: AppColors.accent,
                iconColor: Colors.white,
              ),
              const SizedBox(width: 8),
              Icon(Icons.skip_next_rounded, color: AppColors.iconDefault, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

