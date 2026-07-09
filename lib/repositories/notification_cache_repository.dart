import '../core/storage/hive_storage_service.dart';
import '../models/app_notification.dart';

class NotificationCacheRepository {
  static const _boxName = HiveStorageService.notificationBox;

  Future<List<AppNotification>> getCachedNotifications() async {
    final raw = HiveStorageService.getAll(_boxName);
    final List<AppNotification> results = [];
    for (final item in raw) {
      if (item is Map) {
        results.add(AppNotification.fromJson(item));
      }
    }
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<void> saveNotification(AppNotification notification) async {
    await HiveStorageService.write(
        _boxName, notification.id, notification.toJson());
  }

  Future<void> saveAll(List<AppNotification> notifications) async {
    for (final n in notifications) {
      await HiveStorageService.write(_boxName, n.id, n.toJson());
    }
  }

  Future<void> markAsRead(String id) async {
    final raw = HiveStorageService.read(_boxName, id);
    if (raw is Map) {
      final n = AppNotification.fromJson(raw);
      final updated = n.copyWith(isRead: true);
      await HiveStorageService.write(_boxName, id, updated.toJson());
    }
  }

  Future<void> deleteNotification(String id) async {
    await HiveStorageService.delete(_boxName, id);
  }

  Future<void> clearAll() async {
    await HiveStorageService.clear(_boxName);
  }
}
