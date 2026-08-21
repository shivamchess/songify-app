import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_stream.freezed.dart';
part 'audio_stream.g.dart';

@freezed
class AudioStream with _$AudioStream {
  const factory AudioStream({
    required String url,
    required String title,
    @Default(0) int durationSeconds,
  }) = _AudioStream;

  factory AudioStream.fromJson(Map<String, dynamic> json) =>
      _$AudioStreamFromJson(json);
}

