import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/api_constants.dart';

part 'spotify_auth_service.g.dart';

/// Manages Spotify Client Credentials OAuth flow.
///
/// This is server-to-server auth — no user login required.
/// Tokens expire after 3600s and are auto-refreshed.
@riverpod
SpotifyAuthService spotifyAuthService(Ref ref) {
  return SpotifyAuthService(ref.read(dioProvider));
}

@riverpod
Dio dio(Ref ref) {
  return Dio(BaseOptions(
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
  ));
}

class SpotifyAuthService {
  SpotifyAuthService(this._dio);

  final Dio _dio;
  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Returns a valid Spotify access token, refreshing if expired.
  Future<String> getToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }
    return _refresh();
  }

  Future<String> _refresh() async {
    final credentials = base64Encode(
      utf8.encode(
        '${ApiConstants.spotifyClientId}:${ApiConstants.spotifyClientSecret}',
      ),
    );

    try {
      final response = await _dio.post(
        ApiConstants.spotifyAuthUrl,
        data: 'grant_type=client_credentials',
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final token = response.data['access_token'] as String;
      final expiresIn = response.data['expires_in'] as int;

      _accessToken = token;
      _tokenExpiry =
          DateTime.now().add(Duration(seconds: expiresIn - 60)); // 60s buffer

      return token;
    } on DioException catch (e) {
      throw Exception(
          'Spotify auth failed: ${e.response?.statusCode} ${e.message}');
    }
  }
}

