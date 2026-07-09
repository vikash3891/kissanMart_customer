import '../storage/hive_storage_service.dart';
import '../logging/logger_service.dart';

abstract class RemoteConfigService {
  Future<void> fetchAndActivate();
  bool getBool(String key, {bool defaultValue = false});
  String getString(String key, {String defaultValue = ''});
  int getInt(String key, {int defaultValue = 0});
  String get minimumSupportedVersion;
  bool get isMaintenanceMode;
  bool get forceUpdate;
}

class MockRemoteConfigService implements RemoteConfigService {
  static const _defaults = <String, dynamic>{
    'maintenance_mode': false,
    'force_update': false,
    'minimum_version': '1.0.0',
    'enable_coupons': true,
    'enable_reviews': true,
    'enable_wishlist': true,
    'enable_notifications': true,
    'enable_payments': true,
    'delivery_fee': 30,
    'free_delivery_threshold': 499,
  };

  final Map<String, dynamic> _values = {};

  @override
  Future<void> fetchAndActivate() async {
    final cached = HiveStorageService.read(
      HiveStorageService.remoteConfigBox,
      'config',
    );
    if (cached is Map && !HiveStorageService.isCacheStale(cached)) {
      _values.addAll(Map<String, dynamic>.from(cached['data'] ?? {}));
      LoggerService.info('[RemoteConfig] Loaded from cache');
    } else {
      _values.addAll(_defaults);
      await HiveStorageService.write(
        HiveStorageService.remoteConfigBox,
        'config',
        HiveStorageService.wrapCache(_defaults, const Duration(hours: 6)),
      );
      LoggerService.info('[RemoteConfig] Using defaults (mock)');
    }
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    return (_values[key] ?? _defaults[key] ?? defaultValue) as bool;
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    return (_values[key] ?? _defaults[key] ?? defaultValue).toString();
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    final val = _values[key] ?? _defaults[key] ?? defaultValue;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? defaultValue;
  }

  @override
  String get minimumSupportedVersion =>
      getString('minimum_version', defaultValue: '1.0.0');

  @override
  bool get isMaintenanceMode => getBool('maintenance_mode');

  @override
  bool get forceUpdate => getBool('force_update');
}
