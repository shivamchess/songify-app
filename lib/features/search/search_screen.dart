import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/debouncer.dart';
import '../../state/search/search_provider.dart';
import 'widgets/juicy_search_bar.dart';
import 'widgets/search_suggestions_dropdown.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  // 300ms debounce as requested
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          title: const Text(
            'Search',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // ── Main Content (Categories / Empty State underneath)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80), // Space for search bar overlay
                  
                  // ── Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _CategoryChip(label: 'Top', isSelected: true),
                        _CategoryChip(label: 'Songs'),
                        _CategoryChip(label: 'Playlists'),
                        _CategoryChip(label: 'Artists'),
                        _CategoryChip(label: 'Albums'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Additional UI matching the mockup goes here (e.g., specific lists)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Playlists',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              
              // ── Search Bar & Live Suggestions Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      JuicySearchBar(
                        controller: _controller,
                        onChanged: (q) => _debouncer.run(
                          () => ref.read(searchQueryProvider.notifier).setQuery(q),
                        ),
                        onClear: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                          _unfocus();
                        },
                      ),
                      
                      // Dropdown attaches right below the search bar
                      SearchSuggestionsDropdown(
                        onItemTapped: () {
                          _unfocus();
                          // Keep suggestions open or clear them based on preference.
                          // Usually tapping a result might take you to the player or clear query.
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.isSelected = false});
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.divider,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
      ),
    );
  }
}

