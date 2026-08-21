import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

/// Songify app entry point.
///
/// Startup sequence:
///   1. Flutter engine init
///   2. Hive (local favorites persistence)
///   3. Riverpod ProviderScope
///   4. App widget tree
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Edge-to-edge dark status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // ── Hive init ─────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  await Hive.openBox<String>('favorites');

  runApp(
    const ProviderScope(
      child: SongifyApp(),
    ),
  );
}
