import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../core/logging/logger_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UserProfile? _profile;
  bool _loading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.getProfile();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      LoggerService.error('Failed to load profile', e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? profileImagePath,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.updateLocalProfile(
        name: name,
        email: email,
        profileImagePath: profileImagePath,
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      LoggerService.error('Failed to update profile', e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> clearProfile() async {
    await _repository.clearProfile();
    _profile = null;
    _error = null;
    notifyListeners();
  }

  void clear() {
    _profile = null; _error = null; notifyListeners();
  }
}
