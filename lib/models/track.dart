import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

@freezed
class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    required String artist,
    required String albumName,
    required String albumArtUrl,    // High-res Spotify image URL
    required String albumArtSmall, // 64px thumbnail for mini player
    @Default(0) int durationMs,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  /// Factory from raw Spotify track object
  factory Track.fromSpotify(Map<String, dynamic> item) {
    final images = (item['album']?['images'] as List?) ?? [];
    return Track(
      id: item['id'] as String? ?? '',
      title: item['name'] as String? ?? 'Unknown',
      artist: ((item['artists'] as List?)?.first?['name'] as String?) ?? 'Unknown',
      albumName: item['album']?['name'] as String? ?? '',
      albumArtUrl: images.isNotEmpty ? images.first['url'] as String : '',
      albumArtSmall: images.length >= 3
          ? images[2]['url'] as String
          : (images.isNotEmpty ? images.first['url'] as String : ''),
      durationMs: item['duration_ms'] as int? ?? 0,
    );
  }

  static Track get empty => const Track(
    id: '',
    title: 'No Track',
    artist: 'Unknown',
    albumName: '',
    albumArtUrl: '',
    albumArtSmall: '',
  );
}

