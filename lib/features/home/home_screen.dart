import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../state/playlists/playlists_provider.dart';
import 'widgets/featured_playlists_section.dart';
import 'widgets/section_header.dart';

/// Home tab — shows greeting, featured playlists carousel.
/// Kept under 200 lines; all heavy widgets are extracted.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(featuredPlaylistsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App bar / greeting ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good evening 👋',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'What\'s playing\ntonight?',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
          ),
        ),

        // ── Featured playlists ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 8),
            child: SectionHeader(
              title: 'Featured Playlists',
              onSeeAll: () {},
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: playlistsAsync.when(
            loading: () => const _PlaylistsLoadingShimmer(),
            error: (e, _) => _ErrorTile(message: e.toString()),
            data: (playlists) => FeaturedPlaylistsSection(playlists: playlists),
          ),
        ),

        // Extra bottom padding for mini player
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────

class _PlaylistsLoadingShimmer extends StatelessWidget {
  const _PlaylistsLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, __) => Container(
          width: 160,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        'Failed to load: $message',
        style: const TextStyle(color: AppColors.error, fontSize: 13),
      ),
    );
  }
}
