import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/track.dart';
import '../../models/audio_stream.dart';
import '../../core/constants/api_constants.dart';

part 'python_bridge_service.g.dart';

/// Flutter-side bridge to the embedded Python audio resolver.
///
/// Communication protocol:
///   Flutter → Python: JSON string {"query": "Track Name Artist"}
///   Python → Flutter: JSON string {"url": "...", "title": "...", "duration": 213}
///                  or {"error": "message"} on failure
///
/// The MethodChannel name must match the one registered in native code
/// when setting up serious_python.
@riverpod
PythonBridgeService pythonBridgeService(Ref ref) => PythonBridgeService();

class PythonBridgeService {
  static const MethodChannel _channel =
      MethodChannel(ApiConstants.pythonChannelName);

  bool _initialized = false;

  /// Initialize the serious_python engine.
  /// Must be called once during app startup (in main.dart).
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _channel.invokeMethod<void>('initialize');
      _initialized = true;
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize Python engine: ${e.message}');
    }
  }

  /// Resolve a direct audio stream URL for the given [track].
  ///
  /// Throws an [Exception] if the Python engine returns an error
  /// or if the platform channel call fails.
  Future<AudioStream> resolveStream(Track track) async {
    final query = '${track.title} ${track.artist} audio';
    final payload = jsonEncode({'query': query});

    try {
      final result = await _channel.invokeMethod<String>(
        ApiConstants.pythonMethodResolve,
        payload,
      );

      if (result == null) {
        throw Exception('Python engine returned null response.');
      }

      final Map<String, dynamic> json = jsonDecode(result);

      if (json.containsKey('error')) {
        throw Exception('Python engine error: ${json['error']}');
      }

      return AudioStream.fromJson(json);
    } on PlatformException catch (e) {
      throw Exception('MethodChannel error: ${e.message}');
    }
  }
}
