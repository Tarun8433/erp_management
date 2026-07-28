import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/services/api/endpoints.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late final AuthController controller;
  late final AnimationController _entranceController;
  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          _AnimatedAmbientBackground(
            color: colorScheme.primary,
            controller: _breathController,
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Stagger(
                    controller: _entranceController,
                    index: 0,
                    child: _buildTopBar(context),
                  ),
                  const SizedBox(height: 28),
                  _Stagger(
                    controller: _entranceController,
                    index: 1,
                    child: _buildBrand(context),
                  ),
                  const SizedBox(height: 28),

                  _buildLoginForm(context),

                  // _Stagger(
                  //   controller: _entranceController,
                  //   index: 2,
                  //   child: Obx(
                  //     () => AnimatedSize(
                  //       duration: const Duration(milliseconds: 280),
                  //       curve: Curves.easeOutCubic,
                  //       alignment: Alignment.topCenter,
                  //       child: AnimatedSwitcher(
                  //         duration: const Duration(milliseconds: 360),
                  //         switchInCurve: Curves.easeOutCubic,
                  //         switchOutCurve: Curves.easeInCubic,
                  //         transitionBuilder: (child, animation) {
                  //           return FadeTransition(
                  //             opacity: animation,
                  //             child: SlideTransition(
                  //               position: Tween<Offset>(
                  //                 begin: const Offset(0.06, 0),
                  //                 end: Offset.zero,
                  //               ).animate(animation),
                  //               child: child,
                  //             ),
                  //           );
                  //         },
                  //         child: controller.isLogin.value
                  //             ? _buildLoginForm(context)
                  //             : _buildRegisterForm(context),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  // Social login (Google / Apple) hidden.
                  // _Stagger(
                  //   controller: _entranceController,
                  //   index: 3,
                  //   child: _buildDivider(context),
                  // ),
                  // const SizedBox(height: 20),
                  // _Stagger(
                  //   controller: _entranceController,
                  //   index: 4,
                  //   child: _buildSocialRow(context),
                  // ),
                  // const SizedBox(height: 24),

                  // _Stagger(
                  //   controller: _entranceController,
                  //   index: 5,
                  //   child: Center(
                  //     child: Obx(
                  //       () => AnimatedSwitcher(
                  //         duration: const Duration(milliseconds: 220),
                  //         child: RichText(
                  //           key: ValueKey(controller.isLogin.value),
                  //           text: TextSpan(
                  //             text: controller.isLogin.value
                  //                 ? '${'dont_have_account'.tr} '
                  //                 : '${'already_have_account'.tr} ',
                  //             style: textTheme.bodyMedium?.copyWith(
                  //               color: colorScheme.onSurfaceVariant,
                  //             ),
                  //             children: [
                  //               TextSpan(
                  //                 text: controller.isLogin.value
                  //                     ? 'sign_up'.tr
                  //                     : 'login'.tr,
                  //                 style: textTheme.bodyMedium?.copyWith(
                  //                   color: colorScheme.primary,
                  //                   fontWeight: FontWeight.w700,
                  //                 ),
                  //                 recognizer: TapGestureRecognizer()
                  //                   ..onTap = () {
                  //                     controller.isLogin.value =
                  //                         !controller.isLogin.value;
                  //                   },
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  _Stagger(
                    controller: _entranceController,
                    index: 5,
                    child: Center(
                      child: Obx(
                        () => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: RichText(
                            key: ValueKey(controller.isLogin.value),
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  '${'© 2024 EduManage System. All rights reserved.'.tr} ',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  (controller.isLogin.value ? 'login'.tr : 'register'.tr)
                      .toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (Endpoints.showEnvironmentSelector)
          Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedEnvironment.value,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                isDense: true,
                borderRadius: BorderRadius.circular(12),
                onChanged: (newValue) {
                  if (newValue != null) {
                    controller.changeEnvironment(newValue);
                  }
                },
                items: Endpoints.environments.keys
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrand(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fg =
        ThemeData.estimateBrightnessForColor(colorScheme.primary) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_breathController.value);
              return SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.9 + 0.25 * t,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withValues(
                            alpha: 0.10 * (1 - t),
                          ),
                        ),
                      ),
                    ),
                    Transform.scale(scale: 1 + 0.02 * t, child: child),
                  ],
                ),
              );
            },
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.30),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.school_rounded, color: fg, size: 38),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              controller.isLogin.value ? 'welcome'.tr : 'create_account'.tr,
              key: ValueKey(controller.isLogin.value),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Text(
              controller.isLogin.value
                  ? 'login_required_message'.tr
                  : 'register_subtitle'.tr,
              key: ValueKey('sub-${controller.isLogin.value}'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or_continue_with'.tr,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildSocialRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Google',
            onPressed: controller.onGoogleSignIn,
            type: CustomButtonType.outline,
            assetIcon: 'assets/svgs/g_logo.svg',
            height: 54,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: CustomButton(
            text: 'Apple',
            onPressed: controller.onAppleSignUp,
            type: CustomButtonType.outline,
            icon: Icons.apple,
            height: 54,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return KeyedSubtree(
      key: const ValueKey('login_form'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // _buildSegmentedMethod(context),
          const SizedBox(height: 20),
          Obx(() {
            switch (controller.loginMethod.value) {
              case 'email':
                return Column(
                  children: [
                    CustomTextField(
                      key: const ValueKey('email_field'),
                      focusNode: controller.emailFocusNode,
                      controller: controller.emailController,
                      hintText: 'User Id'.tr,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) =>
                          controller.passwordFocusNode.requestFocus(),
                      suffixIcon: Icon(
                        Icons.email_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: controller.passwordController,
                      focusNode: controller.passwordFocusNode,
                      hintText: 'password'.tr,
                      obscureText: !controller.isPasswordVisible.value,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.onAuthAction(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ],
                );
              case 'phone':
                return CustomTextField(
                  key: const ValueKey('phone_field'),
                  focusNode: controller.phoneFocusNode,
                  controller: controller.phoneController,
                  hintText: 'phone_number'.tr,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => controller.onAuthAction(),
                  suffixIcon: Icon(
                    Icons.phone_android_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              case 'mpin':
                return Column(
                  children: [
                    if (!controller.unlockMode.value) ...[
                      CustomTextField(
                        key: const ValueKey('phone_field'),
                        focusNode: controller.phoneFocusNode,
                        controller: controller.phoneController,
                        hintText: 'Username / Email / Phone',
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            controller.mpinFocusNode.requestFocus(),
                        suffixIcon: Icon(
                          Icons.person_outline,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    CustomTextField(
                      key: const ValueKey('mpin_field'),
                      focusNode: controller.mpinFocusNode,
                      controller: controller.mpinController,
                      hintText: controller.unlockMode.value
                          ? 'Unlock with MPIN'
                          : 'enter_mpin'.tr,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.onAuthAction(),
                      suffixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              default:
                return const SizedBox.shrink();
            }
          }),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => controller.toggleRememberMe(
                    !controller.isRememberMe.value,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: controller.isRememberMe.value
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: controller.isRememberMe.value
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              width: 1.5,
                            ),
                          ),
                          child: controller.isRememberMe.value
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: colorScheme.onPrimary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'remember_me'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(() {
                final isMpin = controller.loginMethod.value == 'mpin';
                return TextButton(
                  onPressed: () {
                    if (isMpin) {
                      Get.toNamed(AppRoutes.forgetMpin);
                    } else {
                      Get.toNamed(AppRoutes.forgetPassword);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isMpin ? 'forgot_mpin_title'.tr : 'forgot_password'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          Obx(
            () => CustomButton(
              text: 'login'.tr,
              onPressed: controller.onAuthAction,
              height: 56,
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedMethod(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final methods = [
      ('email', 'email'.tr, Icons.email_outlined),
      ('phone', 'phone'.tr, Icons.phone_outlined),
      ('mpin', 'mpin'.tr, Icons.lock_outline),
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Obx(() {
        final selectedIndex = methods.indexWhere(
          (m) => m.$1 == controller.loginMethod.value,
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / methods.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutCubic,
                  left: tabWidth * selectedIndex,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: methods.map((m) {
                      final value = m.$1;
                      final label = m.$2;
                      final icon = m.$3;
                      final isSelected = controller.loginMethod.value == value;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.setLoginMethod(value),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: isSelected ? 0.85 : 1.0,
                                  end: isSelected ? 1.0 : 0.92,
                                ),
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutBack,
                                builder: (context, scale, child) =>
                                    Transform.scale(scale: scale, child: child),
                                child: Icon(
                                  icon,
                                  size: 16,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 220),
                                  style: theme.textTheme.labelLarge!.copyWith(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return KeyedSubtree(
      key: const ValueKey('register_form'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: controller.usernameController,
            focusNode: controller.usernameFocusNode,
            hintText: 'username'.tr,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => controller.selectDate(context),
            suffixIcon: Icon(
              Icons.person_outline,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => controller.selectDate(context),
            child: AbsorbPointer(
              child: CustomTextField(
                controller: controller.dobController,
                hintText: 'dob'.tr,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: controller.phoneController,
            focusNode: controller.phoneFocusNode,
            hintText: 'phone_number'.tr,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => controller.emailFocusNode.requestFocus(),
            suffixIcon: Icon(
              Icons.phone_android_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: controller.emailController,
            focusNode: controller.emailFocusNode,
            hintText: 'email'.tr,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => controller.passwordFocusNode.requestFocus(),
            suffixIcon: Icon(
              Icons.email_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => CustomTextField(
              controller: controller.passwordController,
              focusNode: controller.passwordFocusNode,
              hintText: 'password'.tr,
              obscureText: !controller.isPasswordVisible.value,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.onAuthAction(),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'by_signing_up_agree'.tr,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'terms_service'.tr,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  TextSpan(
                    text: 'and'.tr,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: 'privacy_policy'.tr,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  TextSpan(
                    text: 'including'.tr,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: 'cookie_use'.tr,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  TextSpan(
                    text: 'period'.tr,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          CustomButton(
            text: 'sign_up'.tr,
            onPressed: controller.onAuthAction,
            height: 56,
          ),
        ],
      ),
    );
  }
}

class _AnimatedAmbientBackground extends StatelessWidget {
  const _AnimatedAmbientBackground({
    required this.color,
    required this.controller,
  });

  final Color color;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(controller.value);
            final scale1 = 0.95 + 0.10 * t;
            final scale2 = 1.05 - 0.10 * t;
            return Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -80,
                  child: Transform.scale(
                    scale: scale1,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color.withValues(alpha: 0.18),
                            color.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -80,
                  child: Transform.scale(
                    scale: scale2,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stagger extends StatelessWidget {
  const _Stagger({
    required this.controller,
    required this.index,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const total = 6;
    const stagger = 0.08;
    final start = (index * stagger).clamp(0.0, 1.0);
    final end = (start + (1 - (total - 1) * stagger)).clamp(start + 0.01, 1.0);

    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final value = curved.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
