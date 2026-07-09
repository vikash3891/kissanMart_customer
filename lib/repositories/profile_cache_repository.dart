import '../core/storage/hive_storage_service.dart';
import '../models/user_profile.dart';

class ProfileCacheRepository {
  static const _boxName = HiveStorageService.profileBox;
  static const _profileKey = 'current_profile';

  Future<UserProfile?> getCachedProfile() async {
    final raw = HiveStorageService.read(_boxName, _profileKey);
    if (raw is Map) {
      final wrapped = Map<dynamic, dynamic>.from(raw);
      if (!HiveStorageService.isCacheStale(wrapped)) {
        final data = wrapped['data'];
        if (data is Map) {
          return UserProfile.fromJson(data);
        }
      }
    }
    return null;
  }

  Future<void> cacheProfile(UserProfile profile) async {
    final wrapped = HiveStorageService.wrapCache(
      profile.toJson(),
      const Duration(days: 30),
    );
    await HiveStorageService.write(_boxName, _profileKey, wrapped);
  }

  Future<void> clearCache() async {
    await HiveStorageService.clear(_boxName);
  }
}
