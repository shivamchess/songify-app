import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/track.dart';
import '../../services/spotify/spotify_api_service.dart';
import '../../state/player/player_state_notifier.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Track> _results = [];
  bool _loading = false;
  int _selectedTab = 0;
  final _tabs = ['Top', 'Songs', 'Playlists', 'Artists', 'Albums'];

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.trim().isEmpty) {
        setState(() => _results = []);
        return;
      }
      setState(() => _loading = true);
      final api = ref.read(spotifyApiServiceProvider);
      final results = await api.searchTracks(query, limit: 15);
      if (mounted) setState(() { _results = results; _loading = false; });
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
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Search', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearch,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists...',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            onPressed: () { _controller.clear(); setState(() => _results = []); },
                            icon: const Icon(Icons.close, color: AppColors.textMuted),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category tabs
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedTab == i ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: _selectedTab == i ? null : Border.all(color: AppColors.divider),
                    ),
                    child: Text(_tabs[i], style: TextStyle(
                      color: _selectedTab == i ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 64, color: AppColors.accent.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              const Text('Search for your favorite music', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _results.length,
                          itemBuilder: (_, i) => _SearchResultTile(track: _results[i], ref: ref),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.track, required this.ref});
  final Track track;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: track.albumArtSmall.isNotEmpty
            ? CachedNetworkImage(imageUrl: track.albumArtSmall, width: 48, height: 48, fit: BoxFit.cover)
            : Container(width: 48, height: 48, color: AppColors.surfaceElevated, child: const Icon(Icons.music_note, color: AppColors.accent)),
      ),
      title: Text(track.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: AppColors.iconDefault, size: 20)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: AppColors.iconDefault, size: 20)),
        ],
      ),
      onTap: () => ref.read(playerStateNotifierProvider.notifier).playTrack(track),
    );
  }
}
