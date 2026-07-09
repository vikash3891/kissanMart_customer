import '../models/user_profile.dart';
import '../services/auth_service.dart';

class ProfileService {
  final AuthService _authService = AuthService();

  /// Fetches the profile from the backend /auth/me endpoint.
  /// Backend returns: { phone, role, id, created_at }
  /// Name, email, and profile picture are stored locally.
  Future<UserProfile> fetchProfile() async {
    try {
      final userData = await _authService.getCurrentUser();
      return UserProfile(
        phone: userData['phone'] ?? '',
        role: userData['role'] ?? 'CUSTOMER',
        memberSince: DateTime.tryParse(userData['created_at'] ?? ''),
      );
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }
}
