import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../state/player/player_state_notifier.dart';

class NowPlayingPanel extends ConsumerWidget {
  const NowPlayingPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerStateProvider);
    final track = state.currentTrack;
    final size = MediaQuery.sizeOf(context);
    final artSize = size.width * 0.65;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary, size: 28),
        ),
        title: Column(
          children: [
            const Text('PLAYING FROM', style: TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 1.5)),
            const SizedBox(height: 2),
            Text(track.albumName.isNotEmpty ? track.albumName : 'JUICY', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: AppColors.textPrimary)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 1),

            // Circular album art with purple glow
            Container(
              width: artSize,
              height: artSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withOpacity(0.35), blurRadius: 60, spreadRadius: 10),
                ],
              ),
              child: ClipOval(
                child: track.albumArtUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: track.albumArtUrl, fit: BoxFit.cover)
                    : Container(color: AppColors.surfaceElevated, child: const Icon(Icons.music_note, size: 80, color: AppColors.accent)),
              ),
            ),

            const Spacer(flex: 1),

            // Track info + heart
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(track.artist, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite, color: AppColors.accent, size: 28),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress bar
            Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.divider,
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: state.position.inMilliseconds.toDouble().clamp(0, track.durationMs.toDouble().clamp(1, double.infinity)),
                    max: track.durationMs.toDouble().clamp(1, double.infinity),
                    onChanged: (v) => ref.read(playerStateNotifierProvider.notifier).seekTo(Duration(milliseconds: v.toInt())),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(state.position), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(_formatDuration(Duration(milliseconds: track.durationMs)), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => ref.read(playerStateNotifierProvider.notifier).toggleShuffle(),
                  icon: Icon(Icons.shuffle, color: state.isShuffle ? AppColors.accent : AppColors.iconDefault, size: 24),
                ),
                IconButton(
                  onPressed: () => ref.read(playerStateNotifierProvider.notifier).previous(),
                  icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 36),
                ),
                // Big play/pause button
                GestureDetector(
                  onTap: () => ref.read(playerStateNotifierProvider.notifier).togglePlayPause(),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(playerStateNotifierProvider.notifier).next(),
                  icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 36),
                ),
                IconButton(
                  onPressed: () => ref.read(playerStateNotifierProvider.notifier).toggleRepeat(),
                  icon: Icon(Icons.repeat, color: state.isRepeat ? AppColors.accent : AppColors.iconDefault, size: 24),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lyrics preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lyrics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Tap to view full lyrics...', style: TextStyle(fontSize: 13, color: AppColors.accent.withOpacity(0.7), fontStyle: FontStyle.italic)),
                ],
              ),
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
