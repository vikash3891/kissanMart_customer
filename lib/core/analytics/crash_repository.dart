import '../logging/logger_service.dart';

abstract class CrashRepository {
  void recordError(Object error, StackTrace? stackTrace, {bool fatal = false});
  void log(String message);
  void setUserId(String? userId);
}

class MockCrashRepository implements CrashRepository {
  @override
  void recordError(Object error, StackTrace? stackTrace, {bool fatal = false}) {
    LoggerService.error(
        '[Crash] ${fatal ? "FATAL" : "NON-FATAL"}: $error', error, stackTrace);
  }

  @override
  void log(String message) {
    LoggerService.debug('[Crash] Log: $message');
  }

  @override
  void setUserId(String? userId) {
    LoggerService.debug('[Crash] UserId: $userId');
  }
}
