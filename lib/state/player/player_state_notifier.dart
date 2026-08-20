import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/track.dart';
import '../../services/python_bridge/python_bridge_service.dart';

part 'player_state_notifier.g.dart';

// ── State model ──────────────────────────────────────────────────────────────

class PlayerState {
  const PlayerState({
    this.currentTrack = const Track(
      id: '',
      title: 'No Track',
      artist: 'Unknown',
      albumName: '',
      albumArtUrl: '',
      albumArtSmall: '',
    ),
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.isShuffle = false,
    this.isRepeat = false,
    this.position = Duration.zero,
    this.error,
  });

  final Track currentTrack;
  final List<Track> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final bool isShuffle;
  final bool isRepeat;
  final Duration position;
  final String? error;

  PlayerState copyWith({
    Track? currentTrack,
    List<Track>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    bool? isShuffle,
    bool? isRepeat,
    Duration? position,
    String? error,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
      position: position ?? this.position,
      error: error,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────

@riverpod
class PlayerStateNotifier extends _$PlayerStateNotifier {
  late final AudioPlayer _audioPlayer;
  late final PythonBridgeService _bridge;

  @override
  PlayerState build() {
    _audioPlayer = AudioPlayer();
    _bridge = ref.read(pythonBridgeServiceProvider);

    // Sync position tick
    _audioPlayer.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // Sync playing state
    _audioPlayer.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    // Auto-advance on track complete
    _audioPlayer.processingStateStream.listen((ps) {
      if (ps == ProcessingState.completed) next();
    });

    ref.onDispose(() {
      _audioPlayer.dispose();
    });

    return const PlayerState();
  }

  /// Play a single track — resolves stream URL via Python bridge first.
  Future<void> playTrack(Track track, {List<Track>? queue, int index = 0}) async {
    state = state.copyWith(
      currentTrack: track,
      queue: queue ?? [track],
      currentIndex: index,
      isLoading: true,
      error: null,
    );

    try {
      final stream = await _bridge.resolveStream(track);
      await _audioPlayer.setUrl(stream.url);
      await _audioPlayer.play();
      state = state.copyWith(isLoading: false, isPlaying: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  Future<void> next() async {
    if (state.queue.isEmpty) return;
    final nextIndex = (state.currentIndex + 1) % state.queue.length;
    await playTrack(
      state.queue[nextIndex],
      queue: state.queue,
      index: nextIndex,
    );
  }

  Future<void> previous() async {
    if (state.queue.isEmpty) return;
    // If >3s in, restart current track; else go previous
    if (state.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      return;
    }
    final prevIndex =
        (state.currentIndex - 1 + state.queue.length) % state.queue.length;
    await playTrack(
      state.queue[prevIndex],
      queue: state.queue,
      index: prevIndex,
    );
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void toggleShuffle() =>
      state = state.copyWith(isShuffle: !state.isShuffle);

  void toggleRepeat() =>
      state = state.copyWith(isRepeat: !state.isRepeat);
}

@riverpod
PlayerState playerState(Ref ref) => ref.watch(playerStateNotifierProvider);
