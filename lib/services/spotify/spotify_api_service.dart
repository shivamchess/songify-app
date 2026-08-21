import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';

part 'spotify_api_service.g.dart';

@riverpod
SpotifyApiService spotifyApiService(Ref ref) {
  return SpotifyApiService(dio: Dio());
}

class SpotifyApiService {
  SpotifyApiService({required this.dio});

  final Dio dio;

  Track _mapITunesTrack(Map<String, dynamic> item) {
    final artUrl = item['artworkUrl100'] as String? ?? '';
    final highResArt = artUrl.replaceAll('100x100bb', '600x600bb');
    return Track(
      id: item['trackId']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: item['trackName'] as String? ?? 'Unknown Title',
      artist: item['artistName'] as String? ?? 'Unknown Artist',
      albumName: item['collectionName'] as String? ?? 'Unknown Album',
      albumArtUrl: highResArt,
      albumArtSmall: artUrl,
      durationMs: item['trackTimeMillis'] as int? ?? 0,
    );
  }

  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    try {
      final res = await dio.get(
        'https://itunes.apple.com/search',
        queryParameters: {'term': query, 'entity': 'song', 'limit': limit},
      );
      final data = res.data is String ? jsonDecode(res.data as String) : res.data;
      final results = (data as Map<String, dynamic>)['results'] as List? ?? [];
      return results.whereType<Map<String, dynamic>>().map(_mapITunesTrack).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Playlist>> fetchFeaturedPlaylists({int limit = 4}) async {
    // 1. Fetch exact mockup songs for the "Trending" and "Made for You" sections
    final queries = [
      'Baarishein Anuv Jain',
      'Jhoom Ali Sethi',
      'Heeriye Arijit Singh',
      'Lofi Sunset',
      'Dreaming Leavv',
      'Moonlit Idealism'
    ];
    
    final playlists = <Playlist>[];
    
    // Create a special "Trending" playlist that HomeScreen will use
    final trendingTracks = <Track>[];
    for (final q in queries) {
      final res = await searchTracks(q, limit: 1);
      if (res.isNotEmpty) trendingTracks.add(res.first);
    }
    
    // Add Daily Juice
    playlists.add(Playlist(
      id: 'mock_pl_1',
      name: 'Daily Juice',
      description: 'Your daily picks',
      coverUrl: trendingTracks.isNotEmpty ? trendingTracks.first.albumArtUrl : '',
      ownerName: 'JUICY',
      totalTracks: trendingTracks.length,
      tracks: trendingTracks,
    ));

    // Add Night Drive
    final synthwave = await searchTracks('Synthwave', limit: 15);
    playlists.add(Playlist(
      id: 'mock_pl_2',
      name: 'Night Drive',
      description: 'Synthwave vibes',
      coverUrl: synthwave.isNotEmpty ? synthwave.first.albumArtUrl : '',
      ownerName: 'JUICY',
      totalTracks: synthwave.length,
      tracks: synthwave,
    ));

    // Add Lofi Beats
    final lofi = await searchTracks('Lofi Beats', limit: 15);
    playlists.add(Playlist(
      id: 'mock_pl_3',
      name: 'Lofi Beats',
      description: '85 songs',
      coverUrl: lofi.isNotEmpty ? lofi.first.albumArtUrl : '',
      ownerName: 'JUICY',
      totalTracks: lofi.length,
      tracks: lofi,
    ));

    return playlists;
  }

  Future<List<Track>> fetchPlaylistTracks(String playlistId, {int limit = 50}) async {
    return searchTracks('Top Tracks', limit: limit);
  }

  Future<List<Track>> fetchArtistTopTracks(String artistId) async {
    return searchTracks(artistId, limit: 10);
  }
}
