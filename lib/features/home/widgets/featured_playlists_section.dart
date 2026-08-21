import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/playlist.dart';
import 'playlist_card.dart';

/// Horizontal scrolling playlist card carousel.
class FeaturedPlaylistsSection extends StatelessWidget {
  const FeaturedPlaylistsSection({super.key, required this.playlists});
  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: playlists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) => PlaylistCard(
          playlist: playlists[i],
          onTap: () => context.push('/playlist/${playlists[i].id}',
              extra: playlists[i]),
        ),
      ),
    );
  }
}

