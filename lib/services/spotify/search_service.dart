import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/api_constants.dart';
import '../../models/track.dart';
import 'spotify_auth_service.dart';

part 'search_service.g.dart';

@riverpod
SearchService searchService(Ref ref) {
  return SearchService(
    dio: ref.read(dioProvider),
    authService: ref.read(spotifyAuthServiceProvider),
  );
}

/// Service dedicated to search operations, isolated for cleaner architecture.
class SearchService {
  SearchService({required this.dio, required this.authService});

  final Dio dio;
  final SpotifyAuthService authService;

  Future<Options> _authHeaders() async {
    final token = await authService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Live Search Suggestion Engine endpoint.
  /// Hits https://api.spotify.com/v1/search with q={user_input}&type=track,artist&limit=5
  Future<List<Track>> fetchSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    
    final opts = await _authHeaders();
    final res = await dio.get(
      '${ApiConstants.spotifyBaseUrl}/search',
      queryParameters: {
        'q': query,
        'type': 'track,artist',
        'limit': 5,
      },
      options: opts,
    );
    
    // Parse the track results as they perfectly map to our UI requirements
    // (thumbnail, title, artist name).
    final trackItems = res.data['tracks']['items'] as List;
    return trackItems
        .whereType<Map<String, dynamic>>()
        .map(Track.fromSpotify)
        .toList();
  }
}
