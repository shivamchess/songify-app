import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/track.dart';
import '../../services/spotify/search_service.dart';

part 'search_provider.g.dart';

/// Holds the current search query string.
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
  void clear() => state = '';
}

/// Holds the live suggestion results which instantly react to [SearchQuery].
@riverpod
Future<List<Track>> searchSuggestions(Ref ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  
  final api = ref.read(searchServiceProvider);
  return api.fetchSearchSuggestions(query);
}

