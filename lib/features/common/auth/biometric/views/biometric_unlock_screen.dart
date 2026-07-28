import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../../core/utils/local_storage/storage_helper.dart';
import '../../../../../core/utils/role_router.dart';

/// Full-screen biometric unlock gate shown on app launch when the user has
/// enabled biometric login.
///
/// Behaviour:
///  - Auto-prompts the OS biometric sheet as soon as the screen opens.
///  - If the user dismisses or fails, the fingerprint becomes tappable so they
///    can retry with a single tap.
///  - On success, routes to the role-specific landing screen.
///  - If the device no longer supports biometrics, it disables the setting and
///    continues straight to the landing screen (never traps the user).
///  - "Login with password" logs out and returns to the login screen.
class BiometricUnlockScreen extends StatefulWidget {
  const BiometricUnlockScreen({super.key});

  @override
  State<BiometricUnlockScreen> createState() => _BiometricUnlockScreenState();
}

enum _UnlockStatus { authenticating, dismissed, failed }

class _BiometricUnlockScreenState extends State<BiometricUnlockScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _busy = false;
  _UnlockStatus _status = _UnlockStatus.authenticating;
  String? _name;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _loadName();
    // Kick off the prompt after the first frame so the UI is visible behind it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _loadName() async {
    final name = await StorageHelper.getLoginName();
    if (!mounted) return;
    setState(() => _name = name);
  }

  Future<void> _authenticate() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _status = _UnlockStatus.authenticating;
    });

    try {
      final supported =
          await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
      if (!supported) {
        await _disableAndContinue();
        return;
      }

      final available = await _auth.getAvailableBiometrics();
      if (available.isEmpty) {
        await _disableAndContinue();
        return;
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Unlock to continue',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;
      if (didAuthenticate) {
        await RoleRouter.goToLanding();
        return;
      }
      setState(() {
        _busy = false;
        _status = _UnlockStatus.dismissed;
      });
    } on LocalAuthException catch (e) {
      debugPrint('Biometric unlock failed: ${e.code.name} - ${e.description}');
      if (e.code == LocalAuthExceptionCode.noBiometricHardware ||
          e.code == LocalAuthExceptionCode.noBiometricsEnrolled ||
          e.code == LocalAuthExceptionCode.noCredentialsSet) {
        await _disableAndContinue();
        return;
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = _UnlockStatus.failed;
      });
    } catch (e) {
      debugPrint('Biometric unlock unexpected error: $e');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = _UnlockStatus.failed;
      });
    }
  }

  /// The device can no longer perform biometrics — turn the setting off and
  /// let the user into the app rather than stranding them here.
  Future<void> _disableAndContinue() async {
    await StorageHelper.saveBiometricEnabled(false);
    await RoleRouter.goToLanding();
  }

  Future<void> _loginWithPassword() async {
    await RoleRouter.logout();
  }

  String get _statusText {
    switch (_status) {
      case _UnlockStatus.authenticating:
        return 'Authenticating…';
      case _UnlockStatus.dismissed:
        return 'Tap the fingerprint to unlock';
      case _UnlockStatus.failed:
        return 'Authentication failed. Tap to try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SizedBox(
          width: Get.width,
          child: Stack(
            children: [
              _AmbientBackground(color: scheme.primary),
              SizedBox(
              width:   Get.width,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        // Brand mark
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                scheme.primary,
                                scheme.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.28),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Welcome back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (_name != null && _name!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _name!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(flex: 2),
                        // Tappable fingerprint
                        _FingerprintButton(
                          color: scheme.primary,
                          busy: _busy,
                          pulse: _pulse,
                          onTap: _busy ? null : _authenticate,
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _statusText,
                            key: ValueKey(_status),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _status == _UnlockStatus.failed
                                  ? scheme.error
                                  : scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(flex: 3),
                        TextButton.icon(
                          onPressed: _busy ? null : _loginWithPassword,
                          icon: Icon(Icons.password_rounded,
                              size: 18, color: scheme.primary),
                          label: Text(
                            'Login with password',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FingerprintButton extends StatelessWidget {
  const _FingerprintButton({
    required this.color,
    required this.busy,
    required this.pulse,
    required this.onTap,
  });

  final Color color;
  final bool busy;
  final AnimationController pulse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(pulse.value);
          return SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer breathing halo — only when idle (invites the tap).
                if (!busy)
                  Transform.scale(
                    scale: 0.85 + 0.35 * t,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.10 * (1 - t)),
                      ),
                    ),
                  ),
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: busy
                      ? Padding(
                          padding: const EdgeInsets.all(34),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Icon(Icons.fingerprint_rounded, size: 62, color: color),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.16),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.10),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
