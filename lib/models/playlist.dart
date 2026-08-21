import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    required String description,
    required String coverUrl,
    required String ownerName,
    @Default([]) List<Track> tracks,
    @Default(0) int totalTracks,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  factory Playlist.fromSpotify(Map<String, dynamic> json) {
    final images = (json['images'] as List?) ?? [];
    return Playlist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      coverUrl: images.isNotEmpty ? images.first['url'] as String : '',
      ownerName: json['owner']?['display_name'] as String? ?? '',
      totalTracks: json['tracks']?['total'] as int? ?? 0,
    );
  }
}

