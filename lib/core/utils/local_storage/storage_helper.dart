import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/user_data.dart';
import '../../../../core/models/user_details.dart';
import '../../../../core/models/financial_year.dart';
import '../../../features/common/auth/data/models/login_response.dart';
import '../../../features/common/menu/models/menu_response.dart';

class StorageHelper {
  static const String _languageKey = 'selected_language';
  static const String _languagesKey = 'available_languages';
  static const String _themeModeKey = 'theme_mode';
  static const String userDataKey = 'userData';
  static const String financialYearKey = 'financialYear';
  static const String selectedFinancialYearKey = 'selectedFinancialYear';
  static const String selectedCompanyKey = 'selectedCompany';
  static const String selectedCompanyIdKey = 'selectedCompanyId';
  static const String selectedBranchKey = 'selectedBranch';
  static const String selectedBranchIdKey = 'selectedBranchId';
  static const String selectedRoleKey = 'selectedRole';
  static const String selectedRoleIdKey = 'selectedRoleId';
  static const String roleComponentKey = 'roleComponent';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String _isIntroSeenKey = 'is_intro_seen';
  static const String userDetailsKey = 'userDetails';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String biometricPromptedKey = 'biometric_prompted';
  static const String pinSetCompletedKey = 'pin_set_completed';
  static const String dashboardCachePrefix = 'dashboard_cache_';
  static const String tokenKey = 'token';
  static const String tokenExpiryKey = 'token_exp';
  static const String loginNameKey = 'loginName';
  static const String schoolNameKey = 'schoolName';
  static const String _primaryColorKey = 'primary_color';
  static const String _fontSizeKey = 'font_size_multiplier';
  static const String _drawerStyleKey = 'drawer_style';
  static const String _profileImageKey = 'profile_image_path';
  static const String _baseUrlKey = 'selected_base_url';
  static const String _localMpinKey = 'local_mpin_hash';
  static final FlutterSecureStorage _secure = const FlutterSecureStorage();

  // Save base URL
  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }

  // Get base URL
  static Future<String?> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey);
  }

  // Save language code
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // Save available languages
  static Future<void> saveLanguages(List<LanguageData> languages) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      languages.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_languagesKey, encodedData);
  }

  // Get available languages
  static Future<List<LanguageData>> getLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_languagesKey);
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData.map((e) => LanguageData.fromJson(e)).toList();
    }
    return [];
  }

  // Get saved language code
  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  // Save theme mode: 'system' | 'light' | 'dark'
  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  // Get theme mode
  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }

  // Save user data model
  static Future<void> saveUserData(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, jsonEncode(userData.toJson()));
  }

  // Get user data model
  static Future<UserData?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(userDataKey);
    if (userDataString != null) {
      return UserData.fromJson(jsonDecode(userDataString));
    }
    return null;
  }

  // Save financial years
  static Future<void> saveFinancialYears(List<FinancialYear> years) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      years.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(financialYearKey, encodedData);
  }

  // Get financial years
  static Future<List<FinancialYear>> getFinancialYears() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(financialYearKey);
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData.map((e) => FinancialYear.fromJson(e)).toList();
    }
    return [];
  }

  // Save selected financial year
  static Future<void> saveSelectedFinancialYear(FinancialYear year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedFinancialYearKey, jsonEncode(year.toJson()));
  }

  // Get selected financial year
  static Future<FinancialYear?> getSelectedFinancialYear() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(selectedFinancialYearKey);
    if (encodedData != null) {
      return FinancialYear.fromJson(jsonDecode(encodedData));
    }
    return null;
  }

  // Save selected company name
  static Future<void> saveSelectedCompany(String companyName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedCompanyKey, companyName);
  }

  // Get selected company name
  static Future<String?> getSelectedCompany() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedCompanyKey);
  }

  static Future<void> saveSelectedCompanyId(String companyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedCompanyIdKey, companyId);
  }

  static Future<String?> getSelectedCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedCompanyIdKey);
  }

  // Save selected branch name
  static Future<void> saveSelectedBranch(String branchName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedBranchKey, branchName);
  }

  // Get selected branch name
  static Future<String?> getSelectedBranch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedBranchKey);
  }

  // Save & get logged-in user's display name (loginName from API)
  static Future<void> saveLoginName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(loginNameKey, name);
  }

  static Future<String?> getLoginName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(loginNameKey);
  }

  // Save & get school/branch name (name field from login API)
  static Future<void> saveSchoolName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(schoolNameKey, name);
  }

  static Future<String?> getSchoolName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(schoolNameKey);
  }

  static Future<void> saveSelectedBranchId(String branchId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedBranchIdKey, branchId);
  }

  static Future<String?> getSelectedBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedBranchIdKey);
  }

  // Save selected role name
  static Future<void> saveSelectedRole(String roleName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedRoleKey, roleName);
  }

  // Get selected role name
  static Future<String?> getSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedRoleKey);
  }

  static Future<void> saveSelectedRoleId(String roleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedRoleIdKey, roleId);
  }

  static Future<String?> getSelectedRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedRoleIdKey);
  }

  // Save login status
  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, isLoggedIn);
  }

  // Get login status
  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> saveTokenExpiry(int expSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(tokenExpiryKey, expSeconds);
  }

  static Future<int?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(tokenExpiryKey);
  }

  // Clear all user data (for logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userDataKey);
    await prefs.remove(userDetailsKey);
    await prefs.remove(tokenKey);
    await prefs.remove(tokenExpiryKey);
    await prefs.remove(biometricEnabledKey);
    await prefs.remove(biometricPromptedKey);
    await prefs.remove(financialYearKey);
    await prefs.remove(selectedFinancialYearKey);
    await prefs.remove(selectedCompanyKey);
    await prefs.remove(selectedBranchKey);
    await prefs.remove(selectedRoleKey);
    await prefs.remove(selectedRoleIdKey);
    await prefs.remove(_drawerStyleKey);
    await prefs.setBool(isLoggedInKey, false);
    await _secure.delete(key: _localMpinKey);
  }

  static Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secure.deleteAll();
  }

  // Save intro seen status
  static Future<void> saveIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isIntroSeenKey, true);
  }

  // Check if intro is seen
  static Future<bool> isIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isIntroSeenKey) ?? false;
  }

  static Future<void> saveUserDetails(UserDetails details) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDetailsKey, jsonEncode(details.toJson()));
  }

  static Future<UserDetails?> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(userDetailsKey);
    if (s == null) return null;
    return UserDetails.fromJson(jsonDecode(s));
  }

  static Future<void> saveBiometricEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(biometricEnabledKey, v);
  }

  static Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(biometricEnabledKey) ?? false;
  }

  static Future<void> saveBiometricPrompted(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(biometricPromptedKey, v);
  }

  static Future<bool> getBiometricPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(biometricPromptedKey) ?? false;
  }

  static Future<void> markPinSetCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(pinSetCompletedKey, true);
  }

  static Future<bool> wasPinSetJustCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(pinSetCompletedKey) ?? false;
  }

  static Future<void> clearPinSetCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(pinSetCompletedKey, false);
  }

  static Future<void> saveLocalMpin(String mpin) async {
    final bytes = utf8.encode(mpin);
    final digest = sha256.convert(bytes).toString();
    await _secure.write(key: _localMpinKey, value: digest);
  }

  static Future<bool> hasLocalMpin() async {
    final v = await _secure.read(key: _localMpinKey);
    return v != null && v.isNotEmpty;
  }

  static Future<bool> verifyLocalMpin(String mpin) async {
    final saved = await _secure.read(key: _localMpinKey);
    if (saved == null || saved.isEmpty) return false;
    final bytes = utf8.encode(mpin);
    final digest = sha256.convert(bytes).toString();
    return digest == saved;
  }

  static Future<void> saveDashboardCache(
    String lang,
    List<Map<String, dynamic>> list,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$dashboardCachePrefix$lang', jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getDashboardCache(
    String lang,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('$dashboardCachePrefix$lang');
    if (s == null || s.isEmpty) return [];
    final raw = jsonDecode(s) as List;
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // Font Size methods
  static Future<void> saveFontSize(double multiplier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, multiplier);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 1.1;
  }

  // Drawer style methods
  static Future<void> saveDrawerStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_drawerStyleKey, style);
  }

  static Future<String?> getDrawerStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_drawerStyleKey);
  }

  // Primary Color methods
  static Future<void> savePrimaryColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, colorValue);
  }

  static Future<int?> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_primaryColorKey);
  }

  // Save profile image path
  static Future<void> saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, path);
  }

  // Get profile image path
  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }

  // Save role component (Menu Items)
  static Future<void> saveRoleComponent(List<MenuComponent> menuItems) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      menuItems.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(roleComponentKey, encodedData);
  }

  // Get role component (Menu Items)
  static Future<List<MenuComponent>> getRoleComponent() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(roleComponentKey);
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData.map((e) => MenuComponent.fromJson(e)).toList();
    }
    return [];
  }
}
