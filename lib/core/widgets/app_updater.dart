import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';

import 'force_update_view.dart';

/// How long to wait before prompting again after the user taps "Later".
/// Applies to optional (patch) updates only — forced updates never wait.
const _kDurationUntilAlertAgain = Duration(hours: 6);

/// Industry-standard app update prompt widget.
///
/// Version strategy:
///   - **Major / Minor** version change (e.g. 1.x.x → 2.x.x or 1.0.x → 1.1.x) → **Force update**
///     (user CANNOT dismiss, MUST update to continue using the app)
///   - **Patch** version change (e.g. 1.0.1 → 1.0.2) → **Normal update**
///     (user can tap "Ignore" or "Later" and keep using the app)
///
/// Forced updates deliberately bypass [Upgrader]'s display gating
/// (cooldown, "ignore this version", dismissible dialog) and render a
/// blocking full-screen gate instead.
class AppUpdater extends StatefulWidget {
  final Widget child;

  const AppUpdater({super.key, required this.child});

  @override
  State<AppUpdater> createState() => _AppUpdaterState();
}

class _AppUpdaterState extends State<AppUpdater> {
  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    _upgrader = Upgrader(
      // Surface store-lookup failures in debug builds; they are silent otherwise.
      debugLogging: kDebugMode,
      durationUntilAlertAgain: _kDurationUntilAlertAgain,
    );
    // UpgradeAlert normally does this, but the force-update path does not
    // render an UpgradeAlert, so the store lookup must be kicked off here.
    _upgrader.initialize();
  }

  /// A major or minor version bump in the store means the update is mandatory.
  bool _isForceUpdate(UpgraderVersionInfo? versionInfo) {
    final storeVersion = versionInfo?.appStoreVersion;
    final installedVersion = versionInfo?.installedVersion;
    if (storeVersion == null || installedVersion == null) return false;

    return storeVersion.major > installedVersion.major ||
        (storeVersion.major == installedVersion.major &&
            storeVersion.minor > installedVersion.minor);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild once the store version arrives, so the gate can appear as soon
    // as the lookup completes.
    return StreamBuilder<UpgraderState>(
      initialData: _upgrader.state,
      stream: _upgrader.stateStream,
      builder: (context, snapshot) {
        final versionInfo = snapshot.data?.versionInfo;

        if (_isForceUpdate(versionInfo)) {
          return Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              ForceUpdateView(
                appName: _upgrader.appName(),
                storeVersion: versionInfo!.appStoreVersion.toString(),
                installedVersion: versionInfo.installedVersion.toString(),
                onUpdate: _upgrader.sendUserToAppStore,
              ),
            ],
          );
        }

        // Optional update: the standard dismissible upgrader dialog.
        return UpgradeAlert(
          upgrader: _upgrader,
          // This widget sits in GetMaterialApp.builder, which is ABOVE the
          // Navigator, so the local context cannot show a dialog. Use GetX's
          // root navigator key instead.
          navigatorKey: Get.key,
          child: widget.child,
        );
      },
    );
  }
}
