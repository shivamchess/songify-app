import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root application widget.
/// Consumes [appRouterProvider] for GoRouter and applies [AppTheme.dark].
class SongifyApp extends ConsumerWidget {
  const SongifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Songify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      // Ensure full-screen immersive experience
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Prevent font scaling disruptions
          ),
          child: child!,
        );
      },
    );
  }
}
