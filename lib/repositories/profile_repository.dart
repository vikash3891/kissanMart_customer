import '../models/user_profile.dart';
import '../services/profile_service.dart';
import 'profile_cache_repository.dart';

class ProfileRepository {
  final ProfileService _service = ProfileService();
  final ProfileCacheRepository _cache = ProfileCacheRepository();

  /// Loads profile: tries backend first, falls back to cache.
  Future<UserProfile> getProfile() async {
    try {
      final backendProfile = await _service.fetchProfile();
      // Merge with cached local data (name, email, profileImage)
      final cached = await _cache.getCachedProfile();
      final merged = backendProfile.copyWith(
        name: cached?.name,
        email: cached?.email,
        profileImagePath: cached?.profileImagePath,
      );
      await _cache.cacheProfile(merged);
      return merged;
    } catch (_) {
      // Fallback to cache if backend is unavailable
      final cached = await _cache.getCachedProfile();
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Updates local-only profile fields (name, email, profileImage).
  Future<UserProfile> updateLocalProfile({
    String? name,
    String? email,
    String? profileImagePath,
  }) async {
    final current = await _cache.getCachedProfile() ?? UserProfile(phone: '');
    final updated = current.copyWith(
      name: name,
      email: email,
      profileImagePath: profileImagePath,
    );
    await _cache.cacheProfile(updated);
    return updated;
  }

  Future<void> clearProfile() async {
    await _cache.clearCache();
  }
}
