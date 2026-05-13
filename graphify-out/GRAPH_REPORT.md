# Graph Report - lib  (2026-05-05)

## Corpus Check
- Corpus is ~48,078 words - fits in a single context window. You may not need a graph.

## Summary
- 986 nodes · 1166 edges · 42 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Auth & Session Management|Auth & Session Management]]
- [[_COMMUNITY_MPIN & Verification UI|MPIN & Verification UI]]
- [[_COMMUNITY_Role-Based Dashboard|Role-Based Dashboard]]
- [[_COMMUNITY_Home Screen & Banners|Home Screen & Banners]]
- [[_COMMUNITY_Theme & Style System|Theme & Style System]]
- [[_COMMUNITY_Navigation & Drawer|Navigation & Drawer]]
- [[_COMMUNITY_Multi-Role Dashboards|Multi-Role Dashboards]]
- [[_COMMUNITY_API Service & Crypto|API Service & Crypto]]
- [[_COMMUNITY_Signup Flow|Signup Flow]]
- [[_COMMUNITY_Camera & Biometrics|Camera & Biometrics]]
- [[_COMMUNITY_Route & Binding Registry|Route & Binding Registry]]
- [[_COMMUNITY_Theme & App Config|Theme & App Config]]
- [[_COMMUNITY_Profile Management|Profile Management]]
- [[_COMMUNITY_AES Encryption|AES Encryption]]
- [[_COMMUNITY_Settings Screen|Settings Screen]]
- [[_COMMUNITY_Language & Theme Toggle|Language & Theme Toggle]]
- [[_COMMUNITY_Data Models & Services|Data Models & Services]]
- [[_COMMUNITY_App Bootstrap|App Bootstrap]]
- [[_COMMUNITY_API Endpoints|API Endpoints]]
- [[_COMMUNITY_CN Feature|CN Feature]]
- [[_COMMUNITY_Onboarding Flow|Onboarding Flow]]
- [[_COMMUNITY_Auth Dialogs|Auth Dialogs]]
- [[_COMMUNITY_Bottom Navigation Bar|Bottom Navigation Bar]]
- [[_COMMUNITY_Searchable Dropdown|Searchable Dropdown]]
- [[_COMMUNITY_Custom Button|Custom Button]]
- [[_COMMUNITY_Multi-Select Dropdown|Multi-Select Dropdown]]
- [[_COMMUNITY_User Data Models|User Data Models]]
- [[_COMMUNITY_GC Request Model|GC Request Model]]
- [[_COMMUNITY_Hardcoded Enums|Hardcoded Enums]]
- [[_COMMUNITY_Login Response Model|Login Response Model]]
- [[_COMMUNITY_Menu Model|Menu Model]]
- [[_COMMUNITY_User Details|User Details]]
- [[_COMMUNITY_Financial Year|Financial Year]]
- [[_COMMUNITY_App Routes|App Routes]]
- [[_COMMUNITY_Floating Bottom Bar|Floating Bottom Bar]]
- [[_COMMUNITY_Zoom Drawer|Zoom Drawer]]
- [[_COMMUNITY_Drawer State|Drawer State]]
- [[_COMMUNITY_Drawer Style|Drawer Style]]
- [[_COMMUNITY_Drawer Last Action|Drawer Last Action]]
- [[_COMMUNITY_Drawer Styles|Drawer Styles]]
- [[_COMMUNITY_Hindi Locale|Hindi Locale]]
- [[_COMMUNITY_English Locale|English Locale]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 69 edges
2. `package:get/get.dart` - 68 edges
3. `../../../routes/app_routes.dart` - 11 edges
4. `package:flutter/services.dart` - 9 edges
5. `../../../core/utils/local_storage/storage_helper.dart` - 8 edges
6. `../../../core/constants/app_colors.dart` - 8 edges
7. `dart:convert` - 7 edges
8. `package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart` - 7 edges
9. `dart:io` - 7 edges
10. `../../../core/widgets/common_dialog.dart` - 7 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities

### Community 0 - "Auth & Session Management"
Cohesion: 0.03
Nodes (62): ../../auth/data/models/login_response.dart, ../controllers/auth_controller.dart, ../../../../core/utils/crypto/app_secrets.dart, ../../../core/utils/language_refresh_actions.dart, ../../../core/utils/local_storage/storage_helper.dart, ../../../core/widgets/common_dialog.dart, dart:async, ../data/repositories/auth_repository.dart (+54 more)

### Community 1 - "MPIN & Verification UI"
Cohesion: 0.03
Nodes (57): ../controllers/forget_mpin_controller.dart, ../controllers/new_mpin_controller.dart, ../controllers/verification_controller.dart, ../../../core/widgets/custom_button.dart, ../../../core/widgets/custom_text_field.dart, build, Column, CustomTextField (+49 more)

### Community 2 - "Role-Based Dashboard"
Cohesion: 0.04
Nodes (57): ../../../core/models/user_role.dart, ../../../../core/utils/drawer_main/src/flutter_zoom_drawer.dart, ../../../../core/utils/role_router.dart, ../../../../core/widgets/dashboard/alert_card.dart, ../../../../core/widgets/dashboard/dashboard_header.dart, ../../../../core/widgets/dashboard/dashboard_section.dart, ../../../../core/widgets/dashboard/info_tile.dart, ../../../../core/widgets/dashboard/quick_action_button.dart (+49 more)

### Community 3 - "Home Screen & Banners"
Cohesion: 0.03
Nodes (57): AnimatedContainer, _AppBarBackgroundSlider, _AppBarBackgroundSliderState, _BannerCarousel, _BannerCarouselState, _BannerSlide, build, _buildInfoBanner (+49 more)

### Community 4 - "Theme & Style System"
Cohesion: 0.04
Nodes (44): AppColors, BottomBarScrollControllerProvider, of, updateShouldNotify, build, Stack, Style1Widget, build (+36 more)

### Community 5 - "Navigation & Drawer"
Cohesion: 0.04
Nodes (52): ../../../core/utils/bottom_nav_bar/bottom_bar.dart, dart:ui, drawer_styles/drawer_styles.dart, ../../home/home_screen.dart, Function, ZoomDrawerController, AbsorbPointer, _animationStatusListener (+44 more)

### Community 6 - "Multi-Role Dashboards"
Cohesion: 0.04
Nodes (42): ../controllers/driver_dashboard_controller.dart, ../controllers/parent_dashboard_controller.dart, ../controllers/principal_dashboard_controller.dart, ../controllers/splash_controller.dart, ../controllers/teacher_dashboard_controller.dart, AppTranslations, build, Center (+34 more)

### Community 7 - "API Service & Crypto"
Cohesion: 0.05
Nodes (41): ../../../../core/services/api/api_service.dart, ../../../../core/services/api/endpoints.dart, ../../../../core/utils/crypto/aes_crypto.dart, dart:convert, dart:developer, ApiService, _checkTokenExpiration, Duration (+33 more)

### Community 8 - "Signup Flow"
Cohesion: 0.05
Nodes (37): ../controllers/signup_controller.dart, ../../../../core/widgets/custom_dropdown.dart, ../../../../core/widgets/custom_multi_dropdown.dart, dependencies, SignUpBinding, build, _buildBottomNavigation, _buildChip (+29 more)

### Community 9 - "Camera & Biometrics"
Cohesion: 0.05
Nodes (34): custom_camera.dart, dart:io, BiometricRequiredContent, build, Center, Dialog, HomeScreen, Padding (+26 more)

### Community 10 - "Route & Binding Registry"
Cohesion: 0.05
Nodes (36): app_routes.dart, ../features/auth/bindings/auth_binding.dart, ../features/auth/forget_mpin/bindings/forget_mpin_binding.dart, ../features/auth/forget_mpin/views/forget_mpin_screen.dart, ../features/auth/forget_password/bindings/forget_password_binding.dart, ../features/auth/forget_password/views/forget_password_screen.dart, ../features/auth/new_mpin/bindings/new_mpin_binding.dart, ../features/auth/new_mpin/views/new_mpin_screen.dart (+28 more)

### Community 11 - "Theme & App Config"
Cohesion: 0.06
Nodes (32): ../../constants/app_colors.dart, ../../../features/menu/menu_screen.dart, ../../../features/settings/setting_controller.dart, AppTheme, darkTheme, lightTheme, _scaleTextTheme, ThemeData (+24 more)

### Community 12 - "Profile Management"
Cohesion: 0.06
Nodes (33): ../controllers/profile_controller.dart, ../../../core/services/api/dilog/logout_confermation.dart, dependencies, ProfileBinding, Align, build, _buildActionItem, _buildCard (+25 more)

### Community 13 - "AES Encryption"
Cohesion: 0.06
Nodes (28): dart:math, dart:typed_data, AesCrypto, AesEncryptedPayload, decryptCbcPkcs7, encryptCbcPkcs7, _randomBytes, build (+20 more)

### Community 14 - "Settings Screen"
Cohesion: 0.07
Nodes (28): ../language_theme/controllers/language_theme_controller.dart, dependencies, SettingBinding, AlertDialog, build, _buildCard, _buildDivider, _buildSectionHeader (+20 more)

### Community 15 - "Language & Theme Toggle"
Cohesion: 0.07
Nodes (28): ../controllers/language_theme_controller.dart, dependencies, LanguageThemeBinding, _AmbientBackground, AnimatedSwitcher, build, _buildHeader, _buildLanguageTab (+20 more)

### Community 16 - "Data Models & Services"
Cohesion: 0.07
Nodes (26): ../../../core/models/financial_year.dart, ../../../core/models/user_data.dart, ../../../../core/models/user_details.dart, ../../../core/utils/camera/camera_service.dart, ../../../core/utils/gallery/custom_gallery.dart, ../../../core/utils/permissions/permission_handler.dart, ../../../features/auth/data/models/login_response.dart, ../../../features/auth/data/repositories/auth_repository.dart (+18 more)

### Community 17 - "App Bootstrap"
Cohesion: 0.07
Nodes (25): core/bindings/initial_binding.dart, ../../../core/constants/app_colors.dart, core/localization/app_translations.dart, ../../../core/theme/app_theme.dart, build, GetMaterialApp, MyApp, SafeArea (+17 more)

### Community 18 - "API Endpoints"
Cohesion: 0.08
Nodes (23): addGc, changeMpin, changePassword, Endpoints, forgotMpin, forgotPassword, login, loginOtpGenerate (+15 more)

### Community 19 - "CN Feature"
Cohesion: 0.09
Nodes (19): ../controllers/cn_controller.dart, ../data/models/gc_request_model.dart, ../data/repositories/cn_repository.dart, CnBinding, dependencies, CnController, _friendlyError, _loadArguments (+11 more)

### Community 20 - "Onboarding Flow"
Cohesion: 0.09
Nodes (20): ../controllers/onboarding_controller.dart, dependencies, OnboardingBinding, _AmbientBackground, AnimatedContainer, build, _buildBottom, _buildTopBar (+12 more)

### Community 21 - "Auth Dialogs"
Cohesion: 0.11
Nodes (16): ../features/auth/views/auth_screen.dart, build, Dialog, Icon, LoginRequiredContent, Padding, showLoginRequiredDialog, SizedBox (+8 more)

### Community 22 - "Bottom Navigation Bar"
Cohesion: 0.12
Nodes (15): BottomBar, _BottomBarState, build, _buildBottomBar, _buildIcon, Center, dispose, Function (+7 more)

### Community 23 - "Searchable Dropdown"
Cohesion: 0.14
Nodes (13): build, dispose, DraggableScrollableSheet, Expanded, _filter, initState, InkWell, ListTile (+5 more)

### Community 24 - "Custom Button"
Cohesion: 0.15
Nodes (12): build, _buildAssetIcon, _buildButton, _buildContent, CustomButton, ElevatedButton, OutlinedButton, Row (+4 more)

### Community 25 - "Multi-Select Dropdown"
Cohesion: 0.18
Nodes (10): build, CheckboxListTile, Column, Container, CustomMultiDropdown, Divider, DraggableScrollableSheet, _showMultiSelectBottomSheet (+2 more)

### Community 26 - "User Data Models"
Cohesion: 0.25
Nodes (7): BranchInfo, CompanyInfo, RoleInfo, UserBranch, UserCompany, UserData, UserRole

### Community 27 - "GC Request Model"
Cohesion: 0.4
Nodes (4): BookingServiceItem, GcRequestModel, InstructionItem, ShipmentDetail

### Community 28 - "Hardcoded Enums"
Cohesion: 0.5
Nodes (3): DamageSeverity, DamageType, Hardcode

### Community 29 - "Login Response Model"
Cohesion: 0.5
Nodes (3): LanguageData, LoginResponse, LoginResult

### Community 30 - "Menu Model"
Cohesion: 0.5
Nodes (3): MenuComponent, MenuResponse, RoleData

### Community 31 - "User Details"
Cohesion: 1.0
Nodes (1): UserDetails

### Community 32 - "Financial Year"
Cohesion: 1.0
Nodes (1): FinancialYear

### Community 33 - "App Routes"
Cohesion: 1.0
Nodes (1): AppRoutes

### Community 34 - "Floating Bottom Bar"
Cohesion: 1.0
Nodes (0): 

### Community 35 - "Zoom Drawer"
Cohesion: 1.0
Nodes (0): 

### Community 36 - "Drawer State"
Cohesion: 1.0
Nodes (0): 

### Community 37 - "Drawer Style"
Cohesion: 1.0
Nodes (0): 

### Community 38 - "Drawer Last Action"
Cohesion: 1.0
Nodes (0): 

### Community 39 - "Drawer Styles"
Cohesion: 1.0
Nodes (0): 

### Community 40 - "Hindi Locale"
Cohesion: 1.0
Nodes (0): 

### Community 41 - "English Locale"
Cohesion: 1.0
Nodes (0): 

## Knowledge Gaps
- **803 isolated node(s):** `main`, `package:erp_management/app.dart`, `MyApp`, `build`, `GetMaterialApp` (+798 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `User Details`** (2 nodes): `user_details.dart`, `UserDetails`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Financial Year`** (2 nodes): `financial_year.dart`, `FinancialYear`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `App Routes`** (2 nodes): `app_routes.dart`, `AppRoutes`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Floating Bottom Bar`** (1 nodes): `flutter_floating_bottom_bar.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Zoom Drawer`** (1 nodes): `flutter_zoom_drawer.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Drawer State`** (1 nodes): `drawer_state.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Drawer Style`** (1 nodes): `drawer_style.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Drawer Last Action`** (1 nodes): `drawer_last_action.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Drawer Styles`** (1 nodes): `drawer_styles.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Hindi Locale`** (1 nodes): `hi_in.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `English Locale`** (1 nodes): `en_us.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Theme & Style System` to `Auth & Session Management`, `MPIN & Verification UI`, `Role-Based Dashboard`, `Home Screen & Banners`, `Navigation & Drawer`, `Multi-Role Dashboards`, `API Service & Crypto`, `Signup Flow`, `Camera & Biometrics`, `Theme & App Config`, `Profile Management`, `AES Encryption`, `Settings Screen`, `Language & Theme Toggle`, `Data Models & Services`, `App Bootstrap`, `CN Feature`, `Onboarding Flow`, `Auth Dialogs`, `Bottom Navigation Bar`, `Searchable Dropdown`, `Custom Button`, `Multi-Select Dropdown`?**
  _High betweenness centrality (0.471) - this node is a cross-community bridge._
- **Why does `package:get/get.dart` connect `Multi-Role Dashboards` to `Auth & Session Management`, `MPIN & Verification UI`, `Role-Based Dashboard`, `Home Screen & Banners`, `Navigation & Drawer`, `API Service & Crypto`, `Signup Flow`, `Camera & Biometrics`, `Route & Binding Registry`, `Theme & App Config`, `Profile Management`, `AES Encryption`, `Settings Screen`, `Language & Theme Toggle`, `Data Models & Services`, `App Bootstrap`, `CN Feature`, `Onboarding Flow`, `Auth Dialogs`?**
  _High betweenness centrality (0.376) - this node is a cross-community bridge._
- **Why does `dart:convert` connect `API Service & Crypto` to `Data Models & Services`, `Auth & Session Management`, `AES Encryption`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **What connects `main`, `package:erp_management/app.dart`, `MyApp` to the rest of the system?**
  _803 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Auth & Session Management` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `MPIN & Verification UI` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `Role-Based Dashboard` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._