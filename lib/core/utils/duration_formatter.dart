/// Formats a Duration into mm:ss string. e.g. 3:45
extension DurationFormatter on Duration {
  String get mmSs {
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
