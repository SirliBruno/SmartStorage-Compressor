/// Extension on Duration to format standard video durations and ETA times.
extension DurationExtensions on Duration {
  /// Formats duration to mm:ss or hh:mm:ss.
  /// Examples:
  /// Duration(seconds: 92) -> "01:32"
  /// Duration(hours: 1, minutes: 5, seconds: 20) -> "01:05:20"
  String formatDuration() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hrStr = hours.toString().padLeft(2, '0');
      return '$hrStr:$minStr:$secStr';
    } else {
      return '$minStr:$secStr';
    }
  }

  /// Formats short human ETA (e.g., "4 sec", "1 min 20 sec", "45 ثوان").
  String formatEta({bool isArabic = false}) {
    final seconds = inSeconds;
    if (seconds <= 0) return isArabic ? 'أقل من ثانية' : '< 1 sec';

    if (seconds < 60) {
      return isArabic ? '$seconds ثوان' : '$seconds sec';
    }

    final minutes = inMinutes;
    final remainingSecs = seconds.remainder(60);
    if (remainingSecs == 0) {
      return isArabic ? '$minutes دقيقة' : '$minutes min';
    }
    return isArabic
        ? '$minutes دقيقة و $remainingSecs ثانية'
        : '$minutes min $remainingSecs sec';
  }
}
