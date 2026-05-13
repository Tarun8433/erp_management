class Endpoints {
  static const Map<String, String> environments = {
    'Dev': 'https://devapi.schoolclub.in',
    'Prod': 'https://api.schoolclub.in',
  };

  static String baseUrl = environments['Dev']!;

  // Loginetra API base URL (separate service)
  static const String loginetraBaseUrl = 'http://dev.loginetra.com';

  // CN Management
  static Uri addGc() => Uri.parse('$loginetraBaseUrl/api/gc/add-gc');

  // Auth
  static Uri login() => Uri.parse('$baseUrl/api/Account/Login');
  static Uri changePassword() =>
      Uri.parse('$baseUrl/api/Account/ChangePassword');
  static Uri sendResetPasswordLink() =>
      Uri.parse('$baseUrl/api/Account/SendResetPasswordLink');
  static Uri resetPassword() =>
      Uri.parse('$baseUrl/api/Account/ResetPassword');

  // TODO: Below endpoints need to be updated when the new API supports them
  static Uri register() => Uri.parse('$baseUrl/user/add-user');
  static Uri searchUser() => Uri.parse('$baseUrl/user/search-user');

  static Uri otpGenerate() => Uri.parse('$baseUrl/public/otpGenerate');
  static Uri loginOtpGenerate() =>
      Uri.parse('$baseUrl/public/loginOtpGenerate');
  static Uri verifyOtp() => Uri.parse('$baseUrl/public/verify-otp');
  static Uri forgotPassword() => Uri.parse('$baseUrl/public/forgot-password');
  static Uri forgotMpin() => Uri.parse('$baseUrl/public/forgot-mpin');
  static Uri userSetMpin() => Uri.parse('$baseUrl/user/set-mpin');

  // Role
  static Uri switchRole() => Uri.parse('$baseUrl/auth/switch-role');

  // Profile
  static Uri changeMpin() => Uri.parse('$baseUrl/user/change-mpin');

  // SignUp
  static Uri searchState() => Uri.parse('$baseUrl/state/search-state');
  static Uri searchStatusHandler() =>
      Uri.parse('$baseUrl/statusHandler/search-status-handler');
  static Uri searchCity() => Uri.parse('$baseUrl/city/search-city');
  static Uri searchPostalCode() =>
      Uri.parse('$baseUrl/postalCode/search-postalCode');
  static Uri searchCompany() => Uri.parse('$baseUrl/company/search-company');
  static Uri searchBranch() => Uri.parse('$baseUrl/location/search-location');
  static Uri searchRole() => Uri.parse('$baseUrl/role/search-role');

  // In your endpoints.dart file
static Uri uploadDocuments() =>  Uri.parse('$baseUrl/admission/upload-documents');

  // Menu
  static Uri getAppMenu() =>
      Uri.parse('$baseUrl/api/AppMenu/GetAppMenu?isMobileAppRequest=true');
}
