enum AppEnvironment { dev, qa, prod }

class EnvironmentConfig {
  static AppEnvironment _environment = AppEnvironment.dev;

  static void initialize(AppEnvironment env) {
    _environment = env;
  }

  static AppEnvironment get environment => _environment;

  static String get name {
    switch (_environment) {
      case AppEnvironment.dev:
        return 'DEVELOPMENT';
      case AppEnvironment.qa:
        return 'QA';
      case AppEnvironment.prod:
        return 'PRODUCTION';
    }
  }

  static String get baseUrl {
    switch (_environment) {
      case AppEnvironment.dev:
        return "https://kissan-backend-e9rm.onrender.com/api";
      case AppEnvironment.qa:
        return "https://kissan-backend-e9rm.onrender.com/api";
      case AppEnvironment.prod:
        return "https://kissan-backend-e9rm.onrender.com/api";
    }
  }

  static String get googleMapsApiKey {
    return "AIzaSyDummyKeyPlaceholderForMapsIntegration";
  }

  static String get razorpayKey {
    switch (_environment) {
      case AppEnvironment.dev:
      case AppEnvironment.qa:
        return "rzp_test_dummy12345";
      case AppEnvironment.prod:
        return "rzp_live_dummy12345";
    }
  }

  static bool get isDebugLogsEnabled => _environment != AppEnvironment.prod;
}
