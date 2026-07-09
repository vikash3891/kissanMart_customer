import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  /// Requests an OTP to be sent to the given phone number.
  Future<bool> sendOtp(String phone) async {
    try {
      final response = await _apiService.post('/auth/send-otp', {
        'phone': phone,
      });
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  /// Verifies the OTP and returns both access and refresh tokens.
  Future<Map<String, String>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _apiService.post('/auth/verify-otp', {
        'phone': phone,
        'otp': otp,
      });
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        if (accessToken != null && refreshToken != null) {
          return {'accessToken': accessToken, 'refreshToken': refreshToken};
        }
      }
      throw Exception(response['message'] ?? 'Verification failed');
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  /// Gets the currently logged-in user profile details.
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      throw Exception(response['message'] ?? 'Failed to get profile');
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Logs out the user from the backend.
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', {});
    } catch (_) {
      // Ignore network errors on logout
    }
  }
}
