import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import '../../core/theme/app_colors.dart';
import '../../state/player/player_state_notifier.dart';
import '../../state/player/player_panel_notifier.dart';
import 'widgets/album_art_switcher.dart';
import 'widgets/bouncy_play_pause_button.dart';
import 'widgets/elastic_progress_bar.dart';
import 'widgets/track_info_section.dart';

/// The full-screen now-playing panel that slides up from the mini player.
///
/// Architecture:
/// - Hosted inside ShellScreen via [SlidingUpPanel] from sliding_up_panel2
/// - [PanelController] is managed globally via [playerPanelProvider]
/// - The panel snaps between:
///     collapsed  = mini player height only (visible above BottomNav)
///     expanded   = full screen, immersive mode
///
/// Design principles:
/// - Hyper-minimalist: ONLY album art, progress, controls
/// - Background mirrors album art color via ColorFiltered blur (optional)
/// - All controls use [BouncyPlayPauseButton] or [JuicyIconButton]
class NowPlayingPanel extends ConsumerWidget {
  const NowPlayingPanel({super.key, required this.panelController});

  /// Shared controller between the mini player drag handle and this panel
  final PanelController panelController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final track = playerState.currentTrack;
    final isPlaying = playerState.isPlaying;
    final size = MediaQuery.sizeOf(context);

    return SlidingUpPanel(
      controller: panelController,
      minHeight: 0, // Controlled externally by ShellScreen
      maxHeight: size.height,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      color: AppColors.surface,
      backdropEnabled: true,
      backdropColor: Colors.black,
      backdropOpacity: 0.6,
      defaultPanelState: PanelState.CLOSED,
      // The physics-driven drag handle + expanded content
      panelBuilder: () => _PanelContent(
        panelController: panelController,
        isPlaying: isPlaying,
        ref: ref,
      ),
      // Collapsed = zero height (mini player in ShellScreen handles this)
      collapsed: const SizedBox.shrink(),
      body: const SizedBox.shrink(),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal panel content — split out to keep NowPlayingPanel under 200 lines
// ---------------------------------------------------------------------------

class _PanelContent extends StatelessWidget {
  const _PanelContent({
    required this.panelController,
    required this.isPlaying,
    required this.ref,
  });

  final PanelController panelController;
  final bool isPlaying;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final track = playerState.currentTrack;
    final size = MediaQuery.sizeOf(context);

    return Column(
      children: [
        // ── Drag handle ──────────────────────────────────────────────────
        _DragHandle(panelController: panelController),

        const SizedBox(height: 12),

        // ── Album artwork (AnimatedSwitcher) ─────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: AlbumArtSwitcher(
            artUrl: track.albumArtUrl,
            size: size.width - 64,
          ),
        ),

        const SizedBox(height: 32),

        // ── Track info + favorite toggle ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: TrackInfoSection(track: track),
        ),

        const SizedBox(height: 24),

        // ── Elastic seek bar ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ElasticProgressBar(
            position: playerState.position,
            duration: Duration(milliseconds: track.durationMs),
            onSeek: (pos) =>
                ref.read(playerStateNotifierProvider.notifier).seekTo(pos),
          ),
        ),

        const SizedBox(height: 36),

        // ── Playback controls ────────────────────────────────────────────
        _PlaybackControls(isPlaying: isPlaying, ref: ref),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.panelController});
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (panelController.isPanelOpen) {
          panelController.close();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.isPlaying, required this.ref});
  final bool isPlaying;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(playerStateNotifierProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        _ControlButton(
          icon: Icons.shuffle_rounded,
          onTap: notifier.toggleShuffle,
          size: 24,
        ),

        // Previous
        _ControlButton(
          icon: Icons.skip_previous_rounded,
          onTap: notifier.previous,
          size: 36,
        ),

        // Play / Pause — the star of the show
        BouncyPlayPauseButton(
          isPlaying: isPlaying,
          onTap: notifier.togglePlayPause,
        ),

        // Next
        _ControlButton(
          icon: Icons.skip_next_rounded,
          onTap: notifier.next,
          size: 36,
        ),

        // Repeat
        _ControlButton(
          icon: Icons.repeat_rounded,
          onTap: notifier.toggleRepeat,
          size: 24,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// Generic bouncy icon control button (secondary controls like skip/shuffle)
class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.size = 28,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween(begin: 1.0, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onTap() {
    _c.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.75)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 20,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 0.75, end: 1.0)
                .chain(CurveTween(curve: Curves.elasticOut)),
            weight: 80,
          ),
        ]).animate(_c),
        child: Icon(
          widget.icon,
          size: widget.size,
          color: widget.color ?? AppColors.iconDefault,
        ),
      ),
    );
  }
}

