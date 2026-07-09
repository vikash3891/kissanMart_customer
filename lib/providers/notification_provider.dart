import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../repositories/notification_cache_repository.dart';
import '../core/logging/logger_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationCacheRepository _cache = NotificationCacheRepository();

  List<AppNotification> _notifications = [];
  bool _loading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await _cache.getCachedNotifications();
    } catch (e) {
      _error = e.toString();
      LoggerService.error('Failed to load notifications', e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    await _cache.saveNotification(notification);
    _notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _cache.markAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (final n in _notifications) {
      if (!n.isRead) {
        await _cache.markAsRead(n.id);
      }
    }
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _cache.deleteNotification(id);
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _cache.clearAll();
    _notifications.clear();
    notifyListeners();
  }

  /// Creates an order status notification and persists it.
  Future<void> notifyOrderUpdate({
    required String orderId,
    required String status,
  }) async {
    final n = AppNotification(
      id: 'order_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Order Update',
      body: 'Your order #$orderId is now $status.',
      type: 'order',
      createdAt: DateTime.now(),
      deepLink: '/orders/$orderId',
    );
    await addNotification(n);
  }
}
