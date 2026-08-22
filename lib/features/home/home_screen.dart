import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/track.dart';
import '../../models/playlist.dart';
import '../../state/playlists/playlists_provider.dart';
import '../../state/player/player_state_notifier.dart';
import '../../state/favorites/favorites_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _chip = 0;
  final _genres = ['All', 'Mood', 'Workout', 'Chill', 'Party'];

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _username => Hive.box('settings').get('username', defaultValue: 'there') as String;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(featuredPlaylistsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () => ref.refresh(featuredPlaylistsProvider.future),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── Genre chips ─────────────────────────
              SliverToBoxAdapter(child: _buildChips()),

              // ── Made for you ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: _SectionHeader(title: 'Made for you', onSeeAll: () {}),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 190,
                  child: async.when(
                    loading: () => const Center(child: _PulseLoader()),
                    error: (e, _) => _ErrorWidget(onRetry: () => ref.refresh(featuredPlaylistsProvider.future)),
                    data: (playlists) => _PlaylistRow(playlists: playlists),
                  ),
                ),
              ),

              // ── Trending now ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: _SectionHeader(title: 'Trending now', onSeeAll: () {}),
                ),
              ),

              async.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox(height: 200, child: Center(child: _PulseLoader()))),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                data: (playlists) {
                  final tracks = playlists.expand((p) => p.tracks).toList();
                  if (tracks.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text('Pull down to refresh', style: TextStyle(color: AppColors.textMuted)),
                      )),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _TrendingTile(track: tracks[i], index: i + 1, ref: ref),
                      childCount: tracks.length.clamp(0, 15),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                  child: const Text('JUICY', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3)),
                ),
                const SizedBox(height: 4),
                Text('$_greeting, $_username 👋',
                    style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          _IconBtn(icon: Icons.notifications_outlined, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _genres.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => setState(() => _chip = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: _chip == i ? AppColors.primaryGradient : null,
                color: _chip == i ? null : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(_genres[i],
                  style: TextStyle(
                    color: _chip == i ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: _chip == i ? FontWeight.w700 : FontWeight.w500,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Playlist horizontal row ───────────────────────────────────────────────

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({required this.playlists});
  final List<Playlist> playlists;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: playlists.length,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (_, i) => _PlaylistCard(playlist: playlists[i]),
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
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surfaceElevated,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (playlist.coverUrl.isNotEmpty)
            CachedNetworkImage(imageUrl: playlist.coverUrl, fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const _ArtPlaceholder()),
          // Gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
          // Play button
          Positioned(
            top: 10, right: 10,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withOpacity(0.9)),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
          ),
          // Info
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(playlist.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(playlist.description,
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Trending tile ──────────────────────────────────────────────────────────

class _TrendingTile extends ConsumerWidget {
  const _TrendingTile({required this.track, required this.index, required this.ref});
  final Track track;
  final int index;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef w) {
    final isFav = w.watch(favoritesProvider).contains(track.id);
    return InkWell(
      onTap: () => ref.read(playerStateNotifierProvider.notifier).playTrack(track),
      splashFactory: NoSplash.splashFactory,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(children: [
          // Rank number
          SizedBox(
            width: 28,
            child: ShaderMask(
              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
              child: Text('$index', style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          // Art
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: track.albumArtSmall.isNotEmpty
                ? CachedNetworkImage(imageUrl: track.albumArtSmall, width: 50, height: 50, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const _ArtPlaceholder(size: 50))
                : const _ArtPlaceholder(size: 50),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(track.title,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(track.artist,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          // Fav
          GestureDetector(
            onTap: () => w.read(favoritesProvider.notifier).toggleFavorite(track.id),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.pink : AppColors.iconDefault, size: 20),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.more_vert, color: AppColors.iconDefault, size: 20),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Small reusable widgets ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      GestureDetector(onTap: onSeeAll,
          child: ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: const Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          )),
    ],
  );
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    icon: Icon(icon, color: AppColors.textSecondary, size: 24),
    splashFactory: NoSplash.splashFactory,
  );
}

class _ArtPlaceholder extends StatelessWidget {
  const _ArtPlaceholder({this.size = 50});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    color: AppColors.surfaceElevated,
    child: const Icon(Icons.music_note_rounded, color: AppColors.accent, size: 24),
  );
}

class _PulseLoader extends StatelessWidget {
  const _PulseLoader();
  @override
  Widget build(BuildContext context) => const CircularProgressIndicator(
    color: AppColors.accent, strokeWidth: 2,
  );
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 40),
      const SizedBox(height: 8),
      const Text('No connection', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    ]),
  );
}
