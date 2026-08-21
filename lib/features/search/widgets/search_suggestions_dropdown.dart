import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/track.dart';
import '../../../state/search/search_provider.dart';
import '../../../state/player/player_state_notifier.dart';

/// The live search suggestion dropdown overlay.
/// It appears beneath the search bar as a sleek frosted glass container.
/// Animations use AnimatedOpacity and AnimatedContainer with Curves.fastOutSlowIn.
class SearchSuggestionsDropdown extends ConsumerWidget {
  const SearchSuggestionsDropdown({super.key, required this.onItemTapped});

  final VoidCallback onItemTapped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final suggestionsAsync = ref.watch(searchSuggestionsProvider);
    
    final bool isVisible = query.trim().isNotEmpty;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      opacity: isVisible ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        margin: EdgeInsets.only(top: isVisible ? 0 : 10),
        child: isVisible
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 350),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: suggestionsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.accent),
                        ),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading suggestions',
                          style: TextStyle(color: AppColors.error.withOpacity(0.8)),
                        ),
                      ),
                      data: (tracks) {
                        if (tracks.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ),
                          );
                        }
                        
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: tracks.length,
                          separatorBuilder: (_, __) => Divider(
                            color: AppColors.divider.withOpacity(0.5),
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          itemBuilder: (context, i) => _SuggestionItemTile(
                            track: tracks[i],
                            onTap: () {
                              ref.read(playerStateNotifierProvider.notifier).playTrack(tracks[i]);
                              onItemTapped();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _SuggestionItemTile extends StatefulWidget {
  const _SuggestionItemTile({required this.track, required this.onTap});
  
  final Track track;
  final VoidCallback onTap;

  @override
  State<_SuggestionItemTile> createState() => _SuggestionItemTileState();
}

class _SuggestionItemTileState extends State<_SuggestionItemTile> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.95).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 85,
      ),
    ]).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(from: 0),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.track.albumArtSmall.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.track.albumArtSmall,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: AppColors.surface,
                        child: const Icon(Icons.music_note, color: AppColors.iconDefault, size: 20),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.track.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.track.artist,
                      style: const TextStyle(
                        color: AppColors.accentSoft,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.accent,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

