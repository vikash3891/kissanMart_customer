import 'package:flutter/material.dart';
import '../core/design_system/app_colors.dart';
import '../core/storage/hive_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _kPresetKey = 'kk_theme_preset_index';
  static const String _kModeKey = 'kk_theme_mode_index';
  static const String _kAmoledKey = 'kk_theme_amoled_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  AppThemePreset _preset = AppThemePreset.kisaanGreen;
  bool _isAmoled = false;

  ThemeMode get themeMode => _themeMode;
  AppThemePreset get preset => _preset;
  bool get isAmoled => _isAmoled;

  // Helper to get active tokens easily anywhere via context.read/watch<ThemeProvider>().tokens(context)
  AppColorTokens tokens(BuildContext context) {
    final Brightness brightness = _themeMode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (_themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    return AppColors.getTokens(_preset, brightness, isAmoled: _isAmoled);
  }

  ThemeProvider() {
    _loadThemeFromHive();
  }

  void _loadThemeFromHive() {
    try {
      final int? presetIndex =
          HiveStorageService.read(HiveStorageService.settingsBox, _kPresetKey);
      if (presetIndex != null &&
          presetIndex >= 0 &&
          presetIndex < AppThemePreset.values.length) {
        _preset = AppThemePreset.values[presetIndex];
      }

      final int? modeIndex =
          HiveStorageService.read(HiveStorageService.settingsBox, _kModeKey);
      if (modeIndex != null &&
          modeIndex >= 0 &&
          modeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[modeIndex];
      }

      final bool? amoledVal =
          HiveStorageService.read(HiveStorageService.settingsBox, _kAmoledKey);
      if (amoledVal != null) {
        _isAmoled = amoledVal;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await HiveStorageService.write(
        HiveStorageService.settingsBox, _kModeKey, mode.index);
  }

  Future<void> setPreset(AppThemePreset newPreset) async {
    if (_preset == newPreset) return;
    _preset = newPreset;
    notifyListeners();
    await HiveStorageService.write(
        HiveStorageService.settingsBox, _kPresetKey, newPreset.index);
  }

  Future<void> setAmoled(bool enabled) async {
    if (_isAmoled == enabled) return;
    _isAmoled = enabled;
    notifyListeners();
    await HiveStorageService.write(
        HiveStorageService.settingsBox, _kAmoledKey, enabled);
  }

  Future<void> resetToDefault() async {
    _themeMode = ThemeMode.system;
    _preset = AppThemePreset.kisaanGreen;
    _isAmoled = false;
    notifyListeners();
    await HiveStorageService.delete(HiveStorageService.settingsBox, _kModeKey);
    await HiveStorageService.delete(
        HiveStorageService.settingsBox, _kPresetKey);
    await HiveStorageService.delete(
        HiveStorageService.settingsBox, _kAmoledKey);
  }
}
