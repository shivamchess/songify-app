import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';

part 'spotify_api_service.g.dart';

@riverpod
SpotifyApiService spotifyApiService(Ref ref) {
  // We provide a basic Dio instance. 
  // We don't need the SpotifyAuthService anymore since iTunes is public!
  return SpotifyApiService(dio: Dio());
}

/// We are keeping the class name "SpotifyApiService" so we don't break the rest 
/// of our architecture, but under the hood, this now hits the ITUNES SEARCH API!
/// It is 100% free, requires NO API KEYS, and has millions of real tracks.
class SpotifyApiService {
  SpotifyApiService({required this.dio});
  
  final Dio dio;

  // --- Helper to map iTunes JSON to our Track model ---
  Track _mapITunesTrack(Map<String, dynamic> item) {
    final artUrl = item['artworkUrl100'] as String? ?? '';
    // iTunes gives 100x100 images by default. We can get beautiful 600x600 
    // images by simply replacing the dimensions in the URL string!
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

  /// Search the massive iTunes database dynamically.
  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final res = await dio.get(
        'https://itunes.apple.com/search',
        queryParameters: {
          'term': query,
          'entity': 'song',
          'limit': limit,
        },
      );
      
      // iTunes sometimes returns JSON as a String depending on the headers
      final data = res.data is String ? jsonDecode(res.data) : res.data;
      final results = data['results'] as List? ?? [];
      
      return results
          .whereType<Map<String, dynamic>>()
          .map(_mapITunesTrack)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Generate dynamic "featured" playlists by searching real genres!
  Future<List<Playlist>> fetchFeaturedPlaylists({int limit = 4}) async {
    final genres = ['Top Hits', 'Synthwave', 'Lofi Hip Hop', 'Workout', 'Acoustic'];
    genres.shuffle();
    
    final playlists = <Playlist>[];
    
    for (var i = 0; i < limit; i++) {
      final genre = genres[i];
      // Search iTunes for the genre to build a dynamic playlist
      final tracks = await searchTracks(genre, limit: 15);
      
      if (tracks.isNotEmpty) {
        playlists.add(
          Playlist(
            id: 'pl_itunes_$i',
            name: genre,
            description: 'Dynamic $genre playlist pulled from live charts.',
            coverUrl: tracks.first.albumArtUrl, // Use the first track's art as the cover
            ownerName: 'Songify AI',
            totalTracks: tracks.length,
            tracks: tracks,
          )
        );
      }
    }
    return playlists;
  }

  /// Fetch all tracks in a playlist.
  Future<List<Track>> fetchPlaylistTracks(String playlistId, {int limit = 50}) async {
    // Our UI actually reads the tracks directly from the Playlist object we 
    // generated above, so this fallback just does a generic search if called.
    return searchTracks('Top Tracks', limit: limit);
  }

  /// Fetch top tracks for an artist.
  Future<List<Track>> fetchArtistTopTracks(String artistId) async {
    return searchTracks(artistId, limit: 10);
  }
}
