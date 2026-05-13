import 'package:flutter/material.dart';
import 'package:erp_management/core/utils/drawer_main/src/enum/drawer_last_action.dart';
import 'package:erp_management/core/utils/drawer_main/src/enum/drawer_state.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';

extension ZoomDrawerContext on BuildContext {
  /// Drawer
  ZoomDrawerState? get drawer => ZoomDrawer.of(this);

  /// drawerLastAction
  DrawerLastAction? get drawerLastAction =>
      ZoomDrawer.of(this)?.drawerLastAction;

  /// drawerState
  DrawerState? get drawerState => ZoomDrawer.of(this)?.stateNotifier.value;

  /// drawerState notifier
  ValueNotifier<DrawerState>? get drawerStateNotifier =>
      ZoomDrawer.of(this)?.stateNotifier;

  /// Screen Width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen Height
  double get screenHeight => MediaQuery.of(this).size.height;
}
