class AppConstants {
  static const String appName = 'TechBuzz';
  static const String appVersion = '1.0.0';

  static const String bookmarkedNewsKey = 'bookmarked_news';
  static const String userPreferencesKey = 'user_preferences';
  static const String themeKey = 'app_theme';

  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
}
