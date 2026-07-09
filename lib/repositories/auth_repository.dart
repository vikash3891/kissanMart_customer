import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<bool> sendOtp(String phone) {
    return _authService.sendOtp(phone);
  }

  Future<Map<String, String>> verifyOtp(String phone, String otp) {
    return _authService.verifyOtp(phone, otp);
  }

  Future<Map<String, dynamic>> getCurrentUser() {
    return _authService.getCurrentUser();
  }

  Future<void> logout() {
    return _authService.logout();
  }
}
