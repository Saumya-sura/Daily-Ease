class AppConfig {
  static const String appName = 'Daily-Ease';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableDirectCalling = true;
  static const bool enableSocietyDirectory = true;
  static const bool enableCustomRequests = true;
  static const bool enableOfflineCache = true;

  // Supported Locales
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'hi', 'mr'];
}
