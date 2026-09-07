import 'dart:developer' as developer;

/// Lightweight, production-safe structured logger.
abstract class AppLogger {
  static void debug(String message) {
    developer.log('[DEBUG] $message', name: 'SmartStorage');
  }

  static void info(String message) {
    developer.log('[INFO] $message', name: 'SmartStorage');
  }

  static void warn(String message) {
    developer.log('[WARN] $message', name: 'SmartStorage');
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log('[WARN] $message', name: 'SmartStorage', error: error, stackTrace: stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      '[ERROR] $message',
      name: 'SmartStorage',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
