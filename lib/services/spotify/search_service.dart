import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/track.dart';
import 'spotify_api_service.dart';

part 'search_service.g.dart';

@riverpod
SearchService searchService(Ref ref) {
  return SearchService(
    apiService: ref.read(spotifyApiServiceProvider),
  );
}

/// Service dedicated to search operations, isolated for cleaner architecture.
/// Now routes through the local mock API service to bypass Spotify Premium.
class SearchService {
  SearchService({required this.apiService});

  final SpotifyApiService apiService;

  /// Live Search Suggestion Engine endpoint using local mock data.
  Future<List<Track>> fetchSearchSuggestions(String query) async {
    // Just re-use the searchTracks logic which now filters the local JSON
    return apiService.searchTracks(query, limit: 5);
  }
}
