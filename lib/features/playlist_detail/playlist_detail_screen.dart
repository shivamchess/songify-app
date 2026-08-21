import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/playlist.dart';
import '../../state/playlists/playlists_provider.dart';
import '../../state/player/player_state_notifier.dart';
import '../../shared/staggered_list.dart';
import 'widgets/playlist_hero_header.dart';
import 'widgets/track_tile.dart';

/// Playlist detail screen with hero header and staggered track list.
/// Tracks cascade into view with bouncy entrance animations.
class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(playlistTracksProvider(playlist.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header (collapsing app bar with cover art)
          SliverToBoxAdapter(
            child: PlaylistHeroHeader(playlist: playlist),
          ),

          // ── Track list with staggered bounce-in
          tracksAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(
                      color: AppColors.accent),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: $e',
                    style: const TextStyle(color: AppColors.error)),
              ),
            ),
            data: (tracks) => SliverToBoxAdapter(
              child: StaggeredList(
                children: tracks.asMap().entries.map((e) {
                  final track = e.value;
                  return TrackTile(
                    track: track,
                    index: e.key + 1,
                    onTap: () => ref
                        .read(playerStateNotifierProvider.notifier)
                        .playTrack(track, queue: tracks, index: e.key),
                  );
                }).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

