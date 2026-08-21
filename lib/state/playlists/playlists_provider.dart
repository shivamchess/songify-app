import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/playlist.dart';
import '../../models/track.dart';
import '../../services/spotify/spotify_api_service.dart';

part 'playlists_provider.g.dart';

/// Fetches and caches featured playlists from Spotify.
@riverpod
Future<List<Playlist>> featuredPlaylists(Ref ref) async {
  final api = ref.read(spotifyApiServiceProvider);
  return api.fetchFeaturedPlaylists();
}

/// Fetches tracks for a specific playlist.
/// Keyed by [playlistId] so different playlists are cached independently.
@riverpod
Future<List<Track>> playlistTracks(Ref ref, String playlistId) async {
  final api = ref.read(spotifyApiServiceProvider);
  return api.fetchPlaylistTracks(playlistId);
}

