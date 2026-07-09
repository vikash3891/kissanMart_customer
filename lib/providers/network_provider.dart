import 'dart:async';
import 'package:flutter/material.dart';
import '../core/network/network_info.dart';
import '../core/logging/logger_service.dart';

class NetworkProvider extends ChangeNotifier {
  final NetworkInfo _networkInfo = NetworkInfoImpl();
  StreamSubscription<bool>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  NetworkProvider() {
    _init();
  }

  Future<void> _init() async {
    _isOnline = await _networkInfo.isConnected;
    notifyListeners();
    _subscription = _networkInfo.connectionStream.listen((connected) {
      if (_isOnline != connected) {
        _isOnline = connected;
        LoggerService.info(
            'Network status changed: ${connected ? "ONLINE" : "OFFLINE"}');
        notifyListeners();
      }
    });
  }

  Future<bool> checkConnection() async {
    _isOnline = await _networkInfo.isConnected;
    notifyListeners();
    return _isOnline;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
