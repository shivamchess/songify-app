import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/track.dart';
import 'spotify_api_service.dart';

part 'search_service.g.dart';

@riverpod
SearchService searchService(Ref ref) {
  return SearchService(apiService: ref.read(spotifyApiServiceProvider));
}

class SearchService {
  SearchService({required this.apiService});
  final SpotifyApiService apiService;

  Future<List<Track>> fetchSearchSuggestions(String query) async {
    return apiService.searchTracks(query, limit: 5);
  }
}
