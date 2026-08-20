import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/python_bridge/python_bridge_service.dart';

/// Songify app entry point.
///
/// Startup sequence:
///   1. Flutter engine init
///   2. Hive (local favorites persistence)
///   3. Python engine (serious_python bridge)
///   4. Riverpod ProviderScope
///   5. App widget tree
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

  // ── Python bridge init ───────────────────────────────────────────────────
  // Note: serious_python initialization is platform-specific.
  // Uncomment and configure after running the serious_python build step:
  //
  // await SeriousPython.run('assets/python/engine.zip');
  //
  // For now, the bridge will silently fail until the Python bundle is built.
  // See README.md for setup instructions.

  runApp(
    const ProviderScope(
      child: SongifyApp(),
    ),
  );
}
