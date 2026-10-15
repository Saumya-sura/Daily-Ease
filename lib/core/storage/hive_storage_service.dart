import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_logger.dart';

class HiveBoxes {
  static const String appSettings = 'app_settings_box';
  static const String userSession = 'user_session_box';
  static const String categories = 'categories_box';
  static const String providers = 'providers_box';
  static const String bookings = 'bookings_box';
  static const String drafts = 'drafts_box';
  static const String societies = 'societies_box';
  static const String favorites = 'favorites_box';
}

class HiveStorageService {
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox(HiveBoxes.appSettings),
        Hive.openBox(HiveBoxes.userSession),
        Hive.openBox(HiveBoxes.categories),
        Hive.openBox(HiveBoxes.providers),
        Hive.openBox(HiveBoxes.bookings),
        Hive.openBox(HiveBoxes.drafts),
        Hive.openBox(HiveBoxes.societies),
        Hive.openBox(HiveBoxes.favorites),
      ]);
      _isInitialized = true;
      AppLogger.info('HiveStorageService', 'Hive boxes opened successfully');
    } catch (e, st) {
      AppLogger.error('HiveStorageService', 'Failed to initialize Hive', error: e, stackTrace: st);
    }
  }

  Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  // App Settings Helpers
  String getSelectedLocale() {
    return Hive.box(HiveBoxes.appSettings).get('locale', defaultValue: 'en');
  }

  Future<void> setSelectedLocale(String locale) async {
    await Hive.box(HiveBoxes.appSettings).put('locale', locale);
  }

  bool isDarkMode() {
    return Hive.box(HiveBoxes.appSettings).get('is_dark_mode', defaultValue: false);
  }

  Future<void> setDarkMode(bool isDark) async {
    await Hive.box(HiveBoxes.appSettings).put('is_dark_mode', isDark);
  }

  String? getSavedRole() {
    return Hive.box(HiveBoxes.appSettings).get('selected_role');
  }

  Future<void> setSavedRole(String role) async {
    await Hive.box(HiveBoxes.appSettings).put('selected_role', role);
  }

  // Generic Cache Helpers
  dynamic getCached(String boxName, String key) {
    return Hive.box(boxName).get(key);
  }

  Future<void> putCached(String boxName, String key, dynamic value) async {
    await Hive.box(boxName).put(key, value);
  }

  Future<void> deleteCached(String boxName, String key) async {
    await Hive.box(boxName).delete(key);
  }

  Future<void> clearUserSession() async {
    await Hive.box(HiveBoxes.userSession).clear();
    await Hive.box(HiveBoxes.bookings).clear();
    await Hive.box(HiveBoxes.drafts).clear();
    AppLogger.info('HiveStorageService', 'User session and personal cache cleared');
  }
}
