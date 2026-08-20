import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../state/favorites/favorites_notifier.dart';
import '../../state/player/player_state_notifier.dart';
import 'widgets/favorites_track_tile.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Favorites',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            if (favoriteIds.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border_rounded,
                          size: 56, color: AppColors.iconDefault),
                      SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: favoriteIds.length,
                  itemBuilder: (context, i) {
                    final id = favoriteIds.elementAt(i);
                    return FavoritesTrackTile(
                      trackId: id,
                      onRemove: () => ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
