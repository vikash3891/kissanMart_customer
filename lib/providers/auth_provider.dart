import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

/// Manages authentication state.
///
/// On construction, calls [_restoreSession] to check whether a JWT
/// is already stored. This makes the app auto-login without flashing
/// the login screen.
class AuthProvider extends ChangeNotifier {
  final TokenService _tokenService = TokenService();
  final AuthRepository _authRepository = AuthRepository();

  bool _loggedIn = false;
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _currentUser;

  /// True until the async token-check completes on startup.
  bool get isInitializing => _isInitializing;

  /// True when a valid token is present.
  bool get loggedIn => _loggedIn;

  /// True when an authentication request is active.
  bool get isLoading => _isLoading;

  /// Stores any error from the last authentication attempt.
  String? get error => _error;

  /// Stores profile details of current user.
  Map<String, dynamic>? get currentUser => _currentUser;

  AuthProvider() {
    _restoreSession();
  }

  /// Reads the persisted token and sets [_loggedIn] accordingly.
  Future<void> _restoreSession() async {
    _loggedIn = await _tokenService.isLoggedIn();
    if (_loggedIn) {
      await fetchCurrentUser();
    }
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> fetchCurrentUser() async {
    try {
      _currentUser = await _authRepository.getCurrentUser();
    } catch (_) {
      // Ignore profile load errors on restore
    }
    notifyListeners();
  }

  /// Requests a real OTP from the backend.
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _authRepository.sendOtp(phone);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Verifies the OTP on the backend and logs the user in if successful.
  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final tokens = await _authRepository.verifyOtp(phone, otp);
      await login(
        token: tokens['accessToken']!,
        refreshToken: tokens['refreshToken']!,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Persists [token] and [refreshToken] and marks the user as logged in.
  Future<void> login(
      {required String token, required String refreshToken}) async {
    await _tokenService.saveToken(token);
    await _tokenService.saveRefreshToken(refreshToken);
    _loggedIn = true;
    await fetchCurrentUser();
    notifyListeners();
  }

  /// Removes the persisted tokens, notifies backend and marks the user as logged out.
  /// Wrapped in try-finally to ensure local logout happens even if network call throws 401.
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint('[AuthProvider] Logout network error (ignoring): $e');
    } finally {
      await _tokenService.removeTokens();
      _loggedIn = false;
      _currentUser = null;
      notifyListeners();
    }
  }
}
