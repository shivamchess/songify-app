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
    final genres = ['Top Hits', 'Synthwave', 'Lofi Hip Hop', 'Workout', 'Acoustic'];
    genres.shuffle();
    final playlists = <Playlist>[];
    for (var i = 0; i < limit; i++) {
      final genre = genres[i];
      final tracks = await searchTracks(genre, limit: 15);
      if (tracks.isNotEmpty) {
        playlists.add(Playlist(
          id: 'pl_itunes_$i',
          name: genre,
          description: 'Dynamic $genre playlist.',
          coverUrl: tracks.first.albumArtUrl,
          ownerName: 'Songify AI',
          totalTracks: tracks.length,
          tracks: tracks,
        ));
      }
    }
    return playlists;
  }

  Future<List<Track>> fetchPlaylistTracks(String playlistId, {int limit = 50}) async {
    return searchTracks('Top Tracks', limit: limit);
  }

  Future<List<Track>> fetchArtistTopTracks(String artistId) async {
    return searchTracks(artistId, limit: 10);
  }
}
