import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';

class LoggerService {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (EnvironmentConfig.isDebugLogsEnabled) {
      _log('DEBUG', message, error, stackTrace);
    }
  }

  static void info(String message) {
    if (EnvironmentConfig.isDebugLogsEnabled) {
      _log('INFO', message);
    }
  }

  static void warning(String message, [Object? error]) {
    _log('WARNING', message, error);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  static void _log(String level, String message,
      [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final logString = '[$timestamp] [$level] $message';

    if (kDebugMode) {
      // ignore: avoid_print
      print(logString);
      if (error != null) {
        // ignore: avoid_print
        print('Error Details: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('Stack Trace:\n$stackTrace');
      }
    }
  }
}
