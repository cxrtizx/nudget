import 'package:flutter/foundation.dart';

/// Lightweight structured logger that prefixes every message with a [_tag]
/// identifying the originating class or method.
///
/// All output goes through [debugPrint], which is a no-op in release builds,
/// keeping production binaries free of log noise. Replace the implementation
/// here to integrate a third-party logger (e.g. `logger`) without touching
/// call sites.
class Logger {
  /// Creates a [Logger] scoped to [_tag] (typically the class name).
  const Logger(this._tag);

  final String _tag;

  /// Logs an informational [message].
  void info(String message) => debugPrint('[$_tag] INFO  $message');

  /// Logs a [message] indicating a non-fatal condition worth monitoring.
  void warning(String message) => debugPrint('[$_tag] WARN  $message');

  /// Logs an [message] together with the originating [error] and [stackTrace].
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[$_tag] ERROR $message');
    if (error != null) debugPrint('  caused by: $error');
    if (stackTrace != null) debugPrint('  $stackTrace');
  }
}
