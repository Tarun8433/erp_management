import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/local_storage/storage_helper.dart';
import '../../../core/utils/role_router.dart';
import '../../../core/models/user_role.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/services/api/endpoints.dart';
import '../../../core/widgets/common_dialog.dart';

class AuthController extends GetxController {
  // Dependencies
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // State
  final RxBool isLogin = true.obs;
  final RxString loginMethod = 'email'.obs; // 'email', 'phone', 'mpin'
  final RxBool isPasswordVisible = false.obs;
  final RxBool isRememberMe = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool unlockMode = false.obs;

  // Environment Selection
  final RxString selectedEnvironment = 'Dev'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadEnvironment();
    final args = Get.arguments ?? {};
    if (args is Map && args['unlock'] == true) {
      unlockMode.value = true;
      isLogin.value = true;
      loginMethod.value = 'mpin';
      _maybeAutoBiometricUnlock();
    }
  }

  void _loadEnvironment() {
    final currentUrl = Endpoints.baseUrl;
    final entry = Endpoints.environments.entries.firstWhere(
      (e) => e.value == currentUrl,
      orElse: () => const MapEntry('Dev', 'https://devapi.schoolclub.in'),
    );
    selectedEnvironment.value = entry.key;
  }

  Future<void> changeEnvironment(String name) async {
    if (Endpoints.environments.containsKey(name)) {
      final url = Endpoints.environments[name]!;
      Endpoints.baseUrl = url;
      selectedEnvironment.value = name;
      await StorageHelper.saveBaseUrl(url);
      Get.back();
      showCommonDialog(
        title: 'Environment Changed',
        message: 'Switched to $name environment',
        isError: false,
      );
    }
  }

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final dobController = TextEditingController();
  final mpinController = TextEditingController();

  // Focus Nodes
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final mpinFocusNode = FocusNode();
  final usernameFocusNode = FocusNode();

  // Methods
  void toggleMode() {
    isLogin.value = !isLogin.value;
    // Reset fields or state if needed
  }

  void setLoginMethod(String method) {
    loginMethod.value = method;
    if (method != 'mpin') {
      unlockMode.value = false;
    }
    // Request focus for the new method's input field after a slight delay to allow UI rebuild
    Future.delayed(const Duration(milliseconds: 100), () {
      if (method == 'email') {
        emailFocusNode.requestFocus();
      } else if (method == 'phone') {
        phoneFocusNode.requestFocus();
      } else if (method == 'mpin') {
        phoneFocusNode.requestFocus();
      }
    });
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    isRememberMe.value = value ?? false;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime lastDate = DateTime(today.year, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: lastDate, // Future dates disabled
    );

    if (picked != null) {
      dobController.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  void onAuthAction() {
    if (isLogin.value) {
      _login();
    } else {
      Get.toNamed(AppRoutes.signup);
    }
  }

  int? _jwtExpSeconds(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      final normalized = base64.normalize(
        payload.replaceAll('-', '+').replaceAll('_', '/'),
      );
      final decoded = utf8.decode(base64.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is! Map) return null;
      final exp = json['exp'];
      if (exp is int) return exp;
      if (exp is String) return int.tryParse(exp);
      if (exp is num) return exp.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveTokenAndExpiry(String token) async {
    await StorageHelper.saveToken(token);
    final exp = _jwtExpSeconds(token);
    if (exp != null) {
      await StorageHelper.saveTokenExpiry(exp);
    }
  }

  Future<void> _maybePromptBiometricEnable() async {
    final alreadyPrompted = await StorageHelper.getBiometricPrompted();
    if (alreadyPrompted) return;

    final enabled = await Get.to<bool>(() => const _BiometricEnableScreen());
    await StorageHelper.saveBiometricPrompted(true);
    await StorageHelper.saveBiometricEnabled(enabled == true);
  }

  Future<void> _maybeAutoBiometricUnlock() async {
    try {
      final enabled = await StorageHelper.getBiometricEnabled();
      if (!enabled) return;
      final auth = LocalAuthentication();
      final supported =
          await auth.isDeviceSupported() && await auth.canCheckBiometrics;
      if (!supported) {
        await StorageHelper.saveBiometricEnabled(false);
        return;
      }
      final available = await auth.getAvailableBiometrics();
      if (available.isEmpty) {
        await StorageHelper.saveBiometricEnabled(false);
        return;
      }
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Unlock to continue',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (didAuthenticate) {
        await RoleRouter.goToLanding();
      }
    } on LocalAuthException catch (e) {
      debugPrint('Biometric unlock failed: ${e.code.name} - ${e.description}');
      if (e.code == LocalAuthExceptionCode.noBiometricHardware ||
          e.code == LocalAuthExceptionCode.noBiometricsEnrolled ||
          e.code == LocalAuthExceptionCode.noCredentialsSet) {
        await StorageHelper.saveBiometricEnabled(false);
      }
    } catch (e) {
      debugPrint('Biometric unlock unexpected error: $e');
    }
  }

  /// Handles login success response — saves token, branch, role and navigates.
  Future<void> _handleLoginSuccess(dynamic result, String token) async {
    // Save token
    await _saveTokenAndExpiry(token);

    // Save branch info
    if (result.branchId != null) {
      await StorageHelper.saveSelectedBranchId(result.branchId.toString());
    }
    if (result.name != null) {
      await StorageHelper.saveSelectedBranch(result.name!);
    }

    // Save role info — persist canonical enum key so we don't re-parse on every read.
    if (result.role != null && result.role!.isNotEmpty) {
      final raw = result.role!.first;
      final normalized = UserRoleX.fromApi(raw).storageKey;
      await StorageHelper.saveSelectedRole(normalized);
      await StorageHelper.saveSelectedRoleId(raw);
    }

    await StorageHelper.saveLoginStatus(true);
    FocusManager.instance.primaryFocus?.unfocus();
    await _maybePromptBiometricEnable();
    await RoleRouter.goToLanding();
  }

  Future<void> _login() async {
    // Implement login logic based on loginMethod
    print('Login with ${loginMethod.value}');

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showCommonDialog(
        title: 'Error',
        message: 'Please enter username and password',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
        rememberMe: isRememberMe.value,
      );

      if (response.isSuccess && response.result != null) {
        final result = response.result!;
        if (result.token != null) {
          await _handleLoginSuccess(result, result.token!);
        } else {
          showCommonDialog(
            title: 'Error',
            message: 'Login succeeded but no token received',
            isError: true,
          );
        }
      } else {
        showCommonDialog(
          title: 'Error',
          message: response.responseText ?? 'Login failed',
          isError: true,
        );
      }
    } catch (e) {
      print('Login error: $e');
      showCommonDialog(title: 'Error', message: e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void _register() {
    // Implement registration logic
    print('Registering user');
    // Navigate to verification or home
    Get.toNamed(AppRoutes.verification);
  }

  void onGoogleSignIn() {
    print('Google Sign In');
  }

  void onAppleSignUp() {
    print('Apple Sign In');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    dobController.dispose();
    mpinController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    phoneFocusNode.dispose();
    mpinFocusNode.dispose();
    usernameFocusNode.dispose();
    super.onClose();
  }
}

class _BiometricEnableScreen extends StatefulWidget {
  const _BiometricEnableScreen();

  @override
  State<_BiometricEnableScreen> createState() => _BiometricEnableScreenState();
}

class _BiometricEnableScreenState extends State<_BiometricEnableScreen> {
  bool _loading = false;
  bool _checking = true;
  bool _supported = false;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    try {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      final supported = canCheck || await auth.isDeviceSupported();
      if (!mounted) return;
      setState(() {
        _supported = supported;
        _checking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _supported = false;
        _checking = false;
      });
    }
  }

  Future<void> _enable() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final auth = LocalAuthentication();
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        biometricOnly: true,
      );
      if (!mounted) return;
      if (didAuthenticate) {
        Get.back(result: true);
      } else {
        setState(() => _loading = false);
        Get.snackbar(
          'Biometric',
          'Authentication failed',
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      Get.snackbar(
        'Biometric',
        'Authentication failed',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.fingerprint, size: 72, color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Enable Biometric Login',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _checking
                    ? 'Checking biometric availability...'
                    : _supported
                    ? 'Enable biometric login for faster and secure access.'
                    : 'Biometric authentication is not available on this device.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        side: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: _loading
                          ? null
                          : () => Get.back(result: false),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        backgroundColor: colorScheme.primary,
                      ),
                      onPressed: (_loading || _checking || !_supported)
                          ? null
                          : _enable,

                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Enable'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
