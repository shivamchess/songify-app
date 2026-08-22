import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../state/player/player_state_notifier.dart';
import '../../state/favorites/favorites_notifier.dart';

class NowPlayingPanel extends ConsumerWidget {
  const NowPlayingPanel({super.key});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerStateProvider);
    final track = state.currentTrack;
    final isFav = ref.watch(favoritesProvider).contains(track.id);
    final size = MediaQuery.sizeOf(context);
    final artSize = size.width * 0.72;
    final durationMs = track.durationMs.toDouble().clamp(1.0, double.infinity);
    final pos = state.position.inMilliseconds.toDouble().clamp(0.0, durationMs);

    return Container(
      height: size.height * 0.92,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // Blurred background art
          if (track.albumArtUrl.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: CachedNetworkImage(imageUrl: track.albumArtUrl, fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.6), colorBlendMode: BlendMode.darken),
                ),
              ),
            ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Drag handle
                  Container(width: 36, height: 4,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 12),

                  // Top bar
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 30),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      Expanded(child: Column(children: [
                        Text('PLAYING FROM', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5), letterSpacing: 2)),
                        const SizedBox(height: 2),
                        Text(track.albumName.isNotEmpty ? track.albumName : 'JUICY',
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ])),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary, size: 24),
                        splashFactory: NoSplash.splashFactory,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Album art — circular with glow
                  Container(
                    width: artSize, height: artSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 60, spreadRadius: 10),
                        BoxShadow(color: AppColors.pink.withOpacity(0.2), blurRadius: 100, spreadRadius: 20),
                      ],
                    ),
                    child: ClipOval(
                      child: track.albumArtUrl.isNotEmpty
                          ? CachedNetworkImage(imageUrl: track.albumArtUrl, fit: BoxFit.cover)
                          : Container(color: AppColors.surfaceElevated,
                              child: const Icon(Icons.music_note_rounded, size: 80, color: AppColors.accent)),
                    ),
                  ),

                  const Spacer(),

                  // Track info + heart
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(track.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(track.artist,
                          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    ])),
                    GestureDetector(
                      onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(track.id),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          key: ValueKey(isFav),
                          color: isFav ? AppColors.pink : AppColors.iconDefault,
                          size: 28,
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Progress bar
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      activeTrackColor: AppColors.accent,
                      inactiveTrackColor: AppColors.divider,
                      thumbColor: Colors.white,
                      overlayColor: AppColors.accent.withOpacity(0.2),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      value: pos,
                      max: durationMs,
                      onChanged: (v) => ref.read(playerStateNotifierProvider.notifier)
                          .seekTo(Duration(milliseconds: v.toInt())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(_fmt(state.position), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(_fmt(Duration(milliseconds: track.durationMs)),
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ]),
                  ),

                  const SizedBox(height: 16),

                  // Controls
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _CtrlBtn(
                      icon: Icons.shuffle_rounded,
                      active: state.isShuffle,
                      onTap: () => ref.read(playerStateNotifierProvider.notifier).toggleShuffle(),
                    ),
                    _CtrlBtn(
                      icon: Icons.skip_previous_rounded,
                      size: 36,
                      onTap: () => ref.read(playerStateNotifierProvider.notifier).previous(),
                    ),
                    // Main play button
                    GestureDetector(
                      onTap: () => ref.read(playerStateNotifierProvider.notifier).togglePlayPause(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: state.isPlaying ? 72 : 68,
                        height: state.isPlaying ? 72 : 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(state.isPlaying ? 0.6 : 0.3),
                              blurRadius: state.isPlaying ? 30 : 15,
                              spreadRadius: state.isPlaying ? 4 : 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white, size: 38,
                        ),
                      ),
                    ),
                    _CtrlBtn(
                      icon: Icons.skip_next_rounded,
                      size: 36,
                      onTap: () => ref.read(playerStateNotifierProvider.notifier).next(),
                    ),
                    _CtrlBtn(
                      icon: Icons.repeat_rounded,
                      active: state.isRepeat,
                      onTap: () => ref.read(playerStateNotifierProvider.notifier).toggleRepeat(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Lyrics box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.lyrics_outlined, color: AppColors.textSecondary, size: 16),
                        SizedBox(width: 6),
                        Text('Lyrics', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ]),
                      const SizedBox(height: 8),
                      ShaderMask(
                        shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                        child: const Text('Coming soon...', style: TextStyle(fontSize: 14, color: Colors.white, fontStyle: FontStyle.italic)),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  const _CtrlBtn({required this.icon, required this.onTap, this.active = false, this.size = 26});
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: active
        ? ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: Icon(icon, color: Colors.white, size: size),
          )
        : Icon(icon, color: AppColors.iconDefault, size: size),
  );
}
