import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';

part 'spotify_api_service.g.dart';

@riverpod
SpotifyApiService spotifyApiService(Ref ref) {
  return SpotifyApiService();
}

/// Wraps all API calls. Now uses local JSON mocks to bypass Spotify Premium requirement.
class SpotifyApiService {
  SpotifyApiService();

  Future<Map<String, dynamic>> _loadMockData() async {
    final jsonStr = await rootBundle.loadString('assets/data/mock_playlists.json');
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  /// Fetch curated featured playlists from local mock.
  Future<List<Playlist>> fetchFeaturedPlaylists({int limit = 20}) async {
    final data = await _loadMockData();
    final items = data['playlists'] as List;
    
    // Convert directly since our mock maps exactly to our models
    return items
        .whereType<Map<String, dynamic>>()
        .map((json) => Playlist.fromJson(json))
        .toList();
  }

  /// Fetch all tracks in a playlist from local mock.
  Future<List<Track>> fetchPlaylistTracks(String playlistId, {int limit = 50}) async {
    final data = await _loadMockData();
    final items = data['playlists'] as List;
    
    final playlist = items.firstWhere(
      (p) => p['id'] == playlistId, 
      orElse: () => null,
    );
    
    if (playlist == null) return [];
    
    final tracks = playlist['tracks'] as List;
    return tracks
        .whereType<Map<String, dynamic>>()
        .map((json) => Track.fromJson(json))
        .toList();
  }

  /// Search for tracks by query string using local mock data filtering.
  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    
    final data = await _loadMockData();
    final allTracks = <Track>[];
    
    for (final pl in (data['playlists'] as List)) {
      for (final tr in (pl['tracks'] as List)) {
        allTracks.add(Track.fromJson(tr));
      }
    }
    
    final q = query.toLowerCase();
    return allTracks.where((t) {
      return t.title.toLowerCase().contains(q) || t.artist.toLowerCase().contains(q);
    }).take(limit).toList();
  }

  /// Fetch top tracks for an artist from local mock (just a simple filter).
  Future<List<Track>> fetchArtistTopTracks(String artistId) async {
    return searchTracks(artistId); // Quick fake implementation for mock
  }
}
