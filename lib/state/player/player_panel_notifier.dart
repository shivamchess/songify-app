import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

part 'player_panel_notifier.g.dart';

/// Manages the sliding panel expand/collapse state.
/// The [PanelController] is created once and shared between:
///   - ShellScreen (hosts the SlidingUpPanel widget)
///   - MiniPlayerStrip (triggers .open() on tap)
///   - NowPlayingPanel drag handle (triggers .close())
@riverpod
class PlayerPanelNotifier extends _$PlayerPanelNotifier {
  @override
  PanelController build() => PanelController();

  void open() => state.open();
  void close() => state.close();
  bool get isOpen => state.isPanelOpen;
}
