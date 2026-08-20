import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import '../../core/theme/app_colors.dart';
import '../../state/player/player_state_notifier.dart';
import '../../state/player/player_panel_notifier.dart';
import '../now_playing/now_playing_panel.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/mini_player_strip.dart';

/// The persistent shell that frames all three main tabs.
///
/// Layout (bottom-up):
///   BottomNavBar                 ← always visible
///   MiniPlayerStrip              ← floats above nav when track active
///   SlidingUpPanel               ← NowPlayingPanel, 0 height when closed
///   Tab content (child)          ← fills remaining space
class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  static const double _navBarHeight = 72;
  static const double _miniPlayerHeight = 64;

  int _selectedIndex = 0;

  static const List<String> _tabs = ['/home', '/search', '/favorites'];

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    final panelController = ref.watch(playerPanelNotifierProvider);
    final playerState = ref.watch(playerStateProvider);
    final hasTrack = playerState.currentTrack.id.isNotEmpty;

    // Mini player floats above nav; when visible it pushes content up
    final miniPlayerOffset = hasTrack ? _miniPlayerHeight : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Tab content ───────────────────────────────────────────────
          Positioned.fill(
            bottom: _navBarHeight + miniPlayerOffset,
            child: widget.child,
          ),

          // ── Now Playing Panel (slides up from bottom) ─────────────────
          NowPlayingPanel(panelController: panelController),

          // ── Mini Player Strip ──────────────────────────────────────────
          if (hasTrack)
            Positioned(
              left: 0,
              right: 0,
              bottom: _navBarHeight,
              child: MiniPlayerStrip(
                height: _miniPlayerHeight,
                onTap: () => ref
                    .read(playerPanelNotifierProvider.notifier)
                    .open(),
              ),
            ),

          // ── Bottom Navigation Bar ──────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: _onTabTapped,
              height: _navBarHeight,
            ),
          ),
        ],
      ),
    );
  }
}
