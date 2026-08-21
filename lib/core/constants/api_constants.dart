/// All API-related constants. Replace placeholder values with real credentials.
abstract final class ApiConstants {
  // --- Spotify ---
  /// Register at: https://developer.spotify.com/dashboard
  static const String spotifyClientId = String.fromEnvironment(
    'SPOTIFY_CLIENT_ID',
    defaultValue: 'YOUR_SPOTIFY_CLIENT_ID',
  );
  static const String spotifyClientSecret = String.fromEnvironment(
    'SPOTIFY_CLIENT_SECRET',
    defaultValue: 'YOUR_SPOTIFY_CLIENT_SECRET',
  );
  static const String spotifyAuthUrl = 'https://accounts.spotify.com/api/token';
  static const String spotifyBaseUrl = 'https://api.spotify.com/v1';

  // --- Timeouts ---
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // --- Python Bridge ---
  static const String pythonChannelName = 'com.songify/python';
  static const String pythonMethodResolve = 'resolve';
}

