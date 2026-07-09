import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectionStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) return false;
    return await _hasInternetAccess();
  }

  @override
  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.asyncMap((results) async {
      if (results.contains(ConnectivityResult.none)) return false;
      return await _hasInternetAccess();
    });
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
