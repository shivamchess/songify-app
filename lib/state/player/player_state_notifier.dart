import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/track.dart';

part 'player_state_notifier.g.dart';

// ── State model ───────────────────────────────────────────────────────────────

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

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class PlayerStateNotifier extends _$PlayerStateNotifier {
  late final AudioPlayer _player;

  @override
  PlayerState build() {
    _player = AudioPlayer();

    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    _player.processingStateStream.listen((ps) {
      if (ps == ProcessingState.completed) {
        if (state.isRepeat) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          next();
        }
      }
    });

    ref.onDispose(() => _player.dispose());

    return const PlayerState();
  }

  /// Play a track using its iTunes previewUrl (free 30-sec MP3).
  Future<void> playTrack(Track track, {List<Track>? queue, int index = 0}) async {
    state = state.copyWith(
      currentTrack: track,
      queue: queue ?? (state.queue.isEmpty ? [track] : state.queue),
      currentIndex: index,
      isLoading: true,
      error: null,
    );

    if (track.previewUrl.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'No preview available for this track',
      );
      return;
    }

    try {
      await _player.setUrl(track.previewUrl);
      await _player.play();
      state = state.copyWith(isLoading: false, isPlaying: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> next() async {
    if (state.queue.isEmpty) return;
    int nextIndex;
    if (state.isShuffle) {
      final indices = List.generate(state.queue.length, (i) => i)
        ..remove(state.currentIndex);
      if (indices.isEmpty) return;
      indices.shuffle();
      nextIndex = indices.first;
    } else {
      nextIndex = (state.currentIndex + 1) % state.queue.length;
    }
    await playTrack(state.queue[nextIndex], queue: state.queue, index: nextIndex);
  }

  Future<void> previous() async {
    if (state.queue.isEmpty) return;
    if (state.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final prevIndex =
        (state.currentIndex - 1 + state.queue.length) % state.queue.length;
    await playTrack(state.queue[prevIndex], queue: state.queue, index: prevIndex);
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  void toggleShuffle() => state = state.copyWith(isShuffle: !state.isShuffle);
  void toggleRepeat() => state = state.copyWith(isRepeat: !state.isRepeat);
}

@riverpod
PlayerState playerState(Ref ref) => ref.watch(playerStateNotifierProvider);
