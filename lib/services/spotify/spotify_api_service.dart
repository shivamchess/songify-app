import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';

part 'spotify_api_service.g.dart';

@riverpod
SpotifyApiService spotifyApiService(Ref ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ));
  return SpotifyApiService(dio: dio);
}

class SpotifyApiService {
  SpotifyApiService({required this.dio});
  final Dio dio;

  Track _mapTrack(Map<String, dynamic> item) {
    final artUrl = (item['artworkUrl100'] as String? ?? '');
    return Track(
      id: item['trackId']?.toString() ?? '${item['trackName']}${item['artistName']}',
      title: item['trackName'] as String? ?? 'Unknown',
      artist: item['artistName'] as String? ?? 'Unknown',
      albumName: item['collectionName'] as String? ?? '',
      albumArtUrl: artUrl.replaceAll('100x100bb', '600x600bb'),
      albumArtSmall: artUrl,
      durationMs: item['trackTimeMillis'] as int? ?? 0,
    );
  }

  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    try {
      final res = await dio.get(
        'https://itunes.apple.com/search',
        queryParameters: {
          'term': query,
          'entity': 'song',
          'limit': limit,
          'country': 'IN',
        },
      );
      final raw = res.data;
      final Map<String, dynamic> data =
          raw is String ? jsonDecode(raw) as Map<String, dynamic> : raw as Map<String, dynamic>;
      final results = data['results'] as List? ?? [];
      return results.whereType<Map<String, dynamic>>().map(_mapTrack).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Playlist>> fetchFeaturedPlaylists() async {
    // Parallel fetches — all 5 fire at the same time
    final futures = await Future.wait([
      searchTracks('Baarishein Anuv Jain', limit: 1),      // trending seed
      searchTracks('Jhoom Ali Sethi', limit: 1),            // trending seed
      searchTracks('Heeriye Arijit Singh', limit: 1),       // trending seed
      searchTracks('Lofi Chill Hindi', limit: 20),          // Daily Juice
      searchTracks('Synthwave Night Drive', limit: 20),     // Night Drive
      searchTracks('Lofi Beats Study', limit: 20),          // Lofi playlist
    ]);

    final trendingSeeds = [
      if (futures[0].isNotEmpty) futures[0].first,
      if (futures[1].isNotEmpty) futures[1].first,
      if (futures[2].isNotEmpty) futures[2].first,
    ];

    final dailyTracks = futures[3].isNotEmpty ? futures[3] : trendingSeeds;
    final nightTracks = futures[4];
    final lofiTracks = futures[5];

    return [
      Playlist(
        id: 'daily_juice',
        name: 'Daily Juice',
        description: 'Your daily picks',
        coverUrl: dailyTracks.isNotEmpty ? dailyTracks.first.albumArtUrl : '',
        ownerName: 'JUICY',
        totalTracks: dailyTracks.length,
        tracks: dailyTracks,
      ),
      Playlist(
        id: 'night_drive',
        name: 'Night Drive',
        description: 'Synthwave vibes',
        coverUrl: nightTracks.isNotEmpty ? nightTracks.first.albumArtUrl : '',
        ownerName: 'JUICY',
        totalTracks: nightTracks.length,
        tracks: nightTracks,
      ),
      Playlist(
        id: 'lofi_beats',
        name: 'Lofi Beats',
        description: 'Study & chill',
        coverUrl: lofiTracks.isNotEmpty ? lofiTracks.first.albumArtUrl : '',
        ownerName: 'JUICY',
        totalTracks: lofiTracks.length,
        tracks: lofiTracks,
      ),
    ];
  }

  Future<List<Track>> fetchPlaylistTracks(String playlistId, {int limit = 30}) async {
    return searchTracks('Hindi Top Hits', limit: limit);
  }

  Future<List<Track>> fetchArtistTopTracks(String artistId) async {
    return searchTracks(artistId, limit: 10);
  }
}
