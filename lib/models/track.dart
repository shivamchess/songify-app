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
    required String albumArtUrl,
    required String albumArtSmall,
    @Default(0) int durationMs,
    /// 30-second preview MP3 from iTunes — playable with just_audio directly.
    @Default('') String previewUrl,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  static Track get empty => const Track(
        id: '',
        title: 'No Track',
        artist: 'Unknown',
        albumName: '',
        albumArtUrl: '',
        albumArtSmall: '',
      );
}
