class AppConstants {
  // App Info
  static const String appName = 'Notes App';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String notesBoxName = 'notes_box';
  static const String settingsBoxName = 'settings_box';
  static const String userBoxName = 'user_box';
  
  // Firebase Collections
  static const String notesCollection = 'notes';
  static const String usersCollection = 'users';
  
  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String autoSyncKey = 'auto_sync';
  static const String reminderEnabledKey = 'reminder_enabled';
  
  // Note Colors
  static const List<String> noteColors = [
    '#FFFFFFFF', // White
    '#FFF8E1',   // Light Yellow
    '#E8F5E8',   // Light Green
    '#E3F2FD',   // Light Blue
    '#F3E5F5',   // Light Purple
    '#FFEBEE',   // Light Red
    '#FFF3E0',   // Light Orange
    '#E0F2F1',   // Light Teal
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
  static const double padding = 16.0;
}
