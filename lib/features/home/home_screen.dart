import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/track.dart';
import '../../models/playlist.dart';
import '../../state/playlists/playlists_provider.dart';
import '../../state/player/player_state_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedChip = 0;
  final _genres = ['All', 'Mood', 'Workout', 'Chill', 'Party'];

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _username {
    return Hive.box('settings').get('username', defaultValue: 'there') as String;
  }

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(featuredPlaylistsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentSoft],
                      ).createShader(bounds),
                      child: const Text('JUICY', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                    ),
                    Row(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.textPrimary)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_greeting, $_username 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text("Let's groove to something awesome.", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),

            // Genre chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _genres.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => ChoiceChip(
                      label: Text(_genres[i]),
                      selected: _selectedChip == i,
                      onSelected: (s) => setState(() => _selectedChip = i),
                      selectedColor: AppColors.accent,
                      backgroundColor: AppColors.surfaceElevated,
                      labelStyle: TextStyle(
                        color: _selectedChip == i ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ),
            ),

            // "Made for you" section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Made for you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('See all', style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),

            // Horizontal playlist cards
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: playlistsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                  error: (e, _) => Center(child: Text('Failed to load', style: TextStyle(color: AppColors.textMuted))),
                  data: (playlists) => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: playlists.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, i) => _PlaylistCard(playlist: playlists[i]),
                  ),
                ),
              ),
            ),

            // "Trending now" header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Trending now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('See all', style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),

            // Trending song list
            playlistsAsync.when(
              loading: () => const SliverToBoxAdapter(child: SizedBox()),
              error: (e, _) => const SliverToBoxAdapter(child: SizedBox()),
              data: (playlists) {
                final allTracks = playlists.expand((p) => p.tracks).take(10).toList();
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TrendingTile(track: allTracks[i], index: i + 1, ref: ref),
                    childCount: allTracks.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: playlist.coverUrl.isNotEmpty
            ? DecorationImage(image: CachedNetworkImageProvider(playlist.coverUrl), fit: BoxFit.cover)
            : null,
        color: AppColors.surfaceElevated,
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
          // Play button
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.9),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
            ),
          ),
          // Title
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(playlist.description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingTile extends StatelessWidget {
  const _TrendingTile({required this.track, required this.index, required this.ref});
  final Track track;
  final int index;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 24, child: Text('$index', style: const TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.w700))),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: track.albumArtSmall.isNotEmpty
                ? CachedNetworkImage(imageUrl: track.albumArtSmall, width: 48, height: 48, fit: BoxFit.cover)
                : Container(width: 48, height: 48, color: AppColors.surfaceElevated, child: const Icon(Icons.music_note, color: AppColors.accent)),
          ),
        ],
      ),
      title: Text(track.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: AppColors.iconDefault, size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppColors.iconDefault, size: 20),
          ),
        ],
      ),
      onTap: () {
        ref.read(playerStateNotifierProvider.notifier).playTrack(track);
      },
    );
  }
}
