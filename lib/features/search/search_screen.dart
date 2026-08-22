import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/track.dart';
import '../../services/spotify/spotify_api_service.dart';
import '../../state/player/player_state_notifier.dart';
import '../../state/favorites/favorites_notifier.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<Track> _results = [];
  bool _loading = false;
  int _tab = 0;
  final _tabs = ['Top', 'Songs', 'Playlists', 'Artists', 'Albums'];

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (q.trim().isEmpty) { setState(() { _results = []; _loading = false; }); return; }
      setState(() => _loading = true);
      final api = ref.read(spotifyApiServiceProvider);
      final r = await api.searchTracks(q, limit: 20);
      if (mounted) setState(() { _results = r; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Search', style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 28)),
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _ctrl,
                  onChanged: _search,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Songs, artists, albums...',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accent),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(
                            onPressed: () { _ctrl.clear(); setState(() => _results = []); },
                            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                            splashFactory: NoSplash.splashFactory,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tabs
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: _tab == i ? AppColors.primaryGradient : null,
                      color: _tab == i ? null : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Text(_tabs[i], style: TextStyle(
                      color: _tab == i ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w500,
                    )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Results
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
                  : _results.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _results.length,
                          itemBuilder: (_, i) => _ResultTile(track: _results[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    if (_ctrl.text.isNotEmpty && !_loading) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
        const SizedBox(height: 12),
        const Text('No results found', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
      ]));
    }
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ShaderMask(
        shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
        child: const Icon(Icons.search_rounded, color: Colors.white, size: 64),
      ),
      const SizedBox(height: 16),
      const Text('Search for music', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      const Text('Try "Baarishein", "Lofi", "Arijit Singh"',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
    ]));
  }
}

class _ResultTile extends ConsumerWidget {
  const _ResultTile({required this.track});
  final Track track;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(track.id);
    return InkWell(
      onTap: () => ref.read(playerStateNotifierProvider.notifier).playTrack(track),
      splashFactory: NoSplash.splashFactory,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: track.albumArtSmall.isNotEmpty
                ? CachedNetworkImage(imageUrl: track.albumArtSmall, width: 52, height: 52, fit: BoxFit.cover)
                : Container(width: 52, height: 52, color: AppColors.surfaceElevated,
                    child: const Icon(Icons.music_note_rounded, color: AppColors.accent)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(track.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          GestureDetector(
            onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(track.id),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.pink : AppColors.iconDefault, size: 20),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.more_vert, color: AppColors.iconDefault, size: 20),
          ),
        ]),
      ),
    );
  }
}
