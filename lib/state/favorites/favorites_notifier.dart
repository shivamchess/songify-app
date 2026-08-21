import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_notifier.g.dart';

const _boxName = 'favorites';

/// Persists a set of favorite track IDs using Hive.
/// Survives app restarts.
@riverpod
class Favorites extends _$Favorites {
  late final Box<String> _box;

  @override
  Set<String> build() {
    _box = Hive.box<String>(_boxName);
    return _box.values.toSet();
  }

  void toggleFavorite(String trackId) {
    if (state.contains(trackId)) {
      _removeFavorite(trackId);
    } else {
      _addFavorite(trackId);
    }
  }

  void _addFavorite(String trackId) {
    _box.add(trackId);
    state = {...state, trackId};
  }

  void _removeFavorite(String trackId) {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k) == trackId,
      orElse: () => null,
    );
    if (key != null) _box.delete(key);
    state = state.where((id) => id != trackId).toSet();
  }

  bool isFavorite(String trackId) => state.contains(trackId);
}

