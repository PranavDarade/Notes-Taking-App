import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

// Settings State
class SettingsState {
  final ThemeMode themeMode;
  final bool biometricEnabled;
  final bool autoSync;
  final bool reminderEnabled;
  final String language;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.biometricEnabled = false,
    this.autoSync = true,
    this.reminderEnabled = true,
    this.language = 'en',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? biometricEnabled,
    bool? autoSync,
    bool? reminderEnabled,
    String? language,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoSync: autoSync ?? this.autoSync,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      language: language ?? this.language,
    );
  }
}

// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

// Settings Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final themeModeIndex = _prefs.getInt(AppConstants.themeKey) ?? 0;
    final themeMode = ThemeMode.values[themeModeIndex];
    
    final biometricEnabled = _prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
    final autoSync = _prefs.getBool(AppConstants.autoSyncKey) ?? true;
    final reminderEnabled = _prefs.getBool(AppConstants.reminderEnabledKey) ?? true;
    final language = _prefs.getString('language') ?? 'en';

    state = SettingsState(
      themeMode: themeMode,
      biometricEnabled: biometricEnabled,
      autoSync: autoSync,
      reminderEnabled: reminderEnabled,
      language: language,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _prefs.setInt(AppConstants.themeKey, themeMode.index);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.biometricEnabledKey, enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<void> setAutoSync(bool enabled) async {
    await _prefs.setBool(AppConstants.autoSyncKey, enabled);
    state = state.copyWith(autoSync: enabled);
  }

  Future<void> setReminderEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.reminderEnabledKey, enabled);
    state = state.copyWith(reminderEnabled: enabled);
  }

  Future<void> setLanguage(String language) async {
    await _prefs.setString('language', language);
    state = state.copyWith(language: language);
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

// Theme Mode Provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsNotifierProvider).themeMode;
});

// Biometric Enabled Provider
final biometricEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsNotifierProvider).biometricEnabled;
});

// Auto Sync Provider
final autoSyncProvider = Provider<bool>((ref) {
  return ref.watch(settingsNotifierProvider).autoSync;
});

// Reminder Enabled Provider
final reminderEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsNotifierProvider).reminderEnabled;
});
