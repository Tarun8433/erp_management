import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../features/auth/views/auth_screen.dart';

// --- Function to Display the Modal ---
void showLoginRequiredDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? buttonLabel,
  VoidCallback? onButtonPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor ??
            Theme.of(context).cardColor,
        child: LoginRequiredContent(
          title: title,
          message: message,
          buttonLabel: buttonLabel,
          onButtonPressed: onButtonPressed,
        ),
      );
    },
  );
}

// --- The Widget Containing the Lottie Animation and Text ---
class LoginRequiredContent extends StatelessWidget {
  final String? title;
  final String? message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const LoginRequiredContent({
    super.key,
    this.title,
    this.message,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Lottie Animation
          SizedBox(
            height: 150,
            width: 150,
            child: Lottie.asset(
              'assets/lottie/login_animation.json', // Ensure this asset exists
              repeat: true,
              animate: true,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: theme.primaryColor,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 2. Title
          Text(
            title ?? 'login_required_title'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // 3. Message
          Text(
            message ?? 'login_required_message'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),

          const SizedBox(height: 30),

          // 4. Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (onButtonPressed != null) {
                onButtonPressed!();
              } else {
                Get.to(() => const AuthScreen());
              }
            },
            child: Text(
              buttonLabel ?? 'go_to_login'.tr,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
