import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/api_constants.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import 'spotify_auth_service.dart';

part 'spotify_api_service.g.dart';

@riverpod
SpotifyApiService spotifyApiService(Ref ref) {
  return SpotifyApiService(
    dio: ref.read(dioProvider),
    authService: ref.read(spotifyAuthServiceProvider),
  );
}

/// Wraps all Spotify Web API calls.
/// Auth token injection is handled automatically.
class SpotifyApiService {
  SpotifyApiService({required this.dio, required this.authService});

  final Dio dio;
  final SpotifyAuthService authService;

  // ---------------------------------------------------------------------------

  Future<Options> _authHeaders() async {
    final token = await authService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ── Playlists ───────────────────────────────────────────────────────────────

  /// Fetch Spotify's curated featured playlists.
  Future<List<Playlist>> fetchFeaturedPlaylists({int limit = 20}) async {
    final opts = await _authHeaders();
    final res = await dio.get(
      '${ApiConstants.spotifyBaseUrl}/browse/featured-playlists',
      queryParameters: {'limit': limit},
      options: opts,
    );
    final items = res.data['playlists']['items'] as List;
    return items
        .whereType<Map<String, dynamic>>()
        .map(Playlist.fromSpotify)
        .toList();
  }

  /// Fetch all tracks in a playlist.
  Future<List<Track>> fetchPlaylistTracks(String playlistId,
      {int limit = 50}) async {
    final opts = await _authHeaders();
    final res = await dio.get(
      '${ApiConstants.spotifyBaseUrl}/playlists/$playlistId/tracks',
      queryParameters: {'limit': limit, 'fields': 'items(track)'},
      options: opts,
    );
    final items = res.data['items'] as List;
    return items
        .whereType<Map<String, dynamic>>()
        .map((item) => item['track'] as Map<String, dynamic>?)
        .whereType<Map<String, dynamic>>()
        .map(Track.fromSpotify)
        .toList();
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  /// Search for tracks by query string.
  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    final opts = await _authHeaders();
    final res = await dio.get(
      '${ApiConstants.spotifyBaseUrl}/search',
      queryParameters: {
        'q': query,
        'type': 'track',
        'limit': limit,
      },
      options: opts,
    );
    final items = res.data['tracks']['items'] as List;
    return items
        .whereType<Map<String, dynamic>>()
        .map(Track.fromSpotify)
        .toList();
  }

  // ── Artist ──────────────────────────────────────────────────────────────────

  /// Fetch top tracks for an artist (used for related content).
  Future<List<Track>> fetchArtistTopTracks(String artistId) async {
    final opts = await _authHeaders();
    final res = await dio.get(
      '${ApiConstants.spotifyBaseUrl}/artists/$artistId/top-tracks',
      queryParameters: {'market': 'US'},
      options: opts,
    );
    final items = res.data['tracks'] as List;
    return items
        .whereType<Map<String, dynamic>>()
        .map(Track.fromSpotify)
        .toList();
  }
}
