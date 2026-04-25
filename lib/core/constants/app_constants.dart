class AppConstants {
  static const String appName = 'ERP Management';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.erpmanagement.com/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String themeKey = 'app_theme';

  // Pagination
  static const int defaultPageSize = 20;
}
