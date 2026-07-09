import '../logging/logger_service.dart';

abstract class AnalyticsRepository {
  void logEvent(String name, [Map<String, dynamic>? params]);
  void logScreenView(String screenName);
  void setUserId(String? userId);
}

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  void logEvent(String name, [Map<String, dynamic>? params]) {
    LoggerService.debug('[Analytics] Event: $name ${params ?? ''}');
  }

  @override
  void logScreenView(String screenName) {
    LoggerService.debug('[Analytics] Screen: $screenName');
  }

  @override
  void setUserId(String? userId) {
    LoggerService.debug('[Analytics] UserId: $userId');
  }
}
