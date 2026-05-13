import 'package:flutter/material.dart';

import 'package:erp_management/core/utils/drawer_main/src/enum/drawer_state.dart';

class ZoomDrawerController {
  /// Open drawer
  TickerFuture? Function()? open;

  /// Close drawer
  TickerFuture? Function()? close;

  /// Toggle drawer
  TickerFuture? Function({bool forceToggle})? toggle;

  /// Determine if status of drawer equals to Open
  bool Function()? isOpen;

  /// Drawer state notifier
  /// opening, closing, open, closed
  ValueNotifier<DrawerState>? stateNotifier;
}
