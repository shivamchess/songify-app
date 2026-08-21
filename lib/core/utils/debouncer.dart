import 'dart:async';
import 'package:flutter/foundation.dart';

/// A simple debouncer for search field inputs.
/// Usage: _debouncer.run(() => ref.read(searchProvider.notifier).search(query));
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 400)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}

