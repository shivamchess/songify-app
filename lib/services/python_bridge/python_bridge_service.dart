import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/api_constants.dart';
import '../../models/track.dart';
import '../../models/audio_stream.dart';

part 'python_bridge_service.g.dart';

@riverpod
PythonBridgeService pythonBridgeService(Ref ref) => PythonBridgeService();

class PythonBridgeService {
  static const MethodChannel _channel =
      MethodChannel(ApiConstants.pythonChannelName);

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _channel.invokeMethod<void>('initialize');
      _initialized = true;
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize Python engine: ${e.message}');
    }
  }

  Future<AudioStream> resolveStream(Track track) async {
    final query = '${track.title} ${track.artist} audio';
    final payload = jsonEncode({'query': query});
    try {
      final result = await _channel.invokeMethod<String>(
        ApiConstants.pythonMethodResolve,
        payload,
      );
      if (result == null) throw Exception('Python engine returned null response.');
      final Map<String, dynamic> json = jsonDecode(result);
      if (json.containsKey('error')) throw Exception('Python engine error: ${json['error']}');
      return AudioStream.fromJson(json);
    } on PlatformException catch (e) {
      throw Exception('MethodChannel error: ${e.message}');
    }
  }
}
