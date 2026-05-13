import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../routes/app_routes.dart';
import '../../../utils/local_storage/storage_helper.dart';

// Note: Assuming you have a function or service to handle the actual logout process.
// For this example, we'll use a placeholder action.

// --- Function to Display the Modal ---
void showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // User can tap outside to close
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0,
        backgroundColor: context.theme.cardColor,
        child: const LogoutConfirmationContent(),
      );
    },
  );
}

// --- The Widget Containing the Lottie Animation and Text ---
class LogoutConfirmationContent extends StatelessWidget {
  const LogoutConfirmationContent({super.key});

  // Placeholder for the actual logout logic
  void _performLogout(BuildContext context) async {
    // 1. Close the dialog
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop();
    await StorageHelper.clearUserData();
    Get.offAllNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Lottie Animation (Use an animation that suggests logging out or confirming action)
          SizedBox(
            height: 150,
            width: 150,
            child: Lottie.asset(
              // IMPORTANT: Replace this with the path to a suitable Lottie JSON file (e.g., a door, checkmark, or confirmation icon)
              'assets/lottie/Log out.json',
              repeat:
                  false, // Don't repeat, a single visual confirmation might be better
              animate: true,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 20),

          // 2. Title
          Text(
            'logout_confirmation_title'.tr,
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // 3. Message
          Text(
            'logout_confirmation_message'.tr,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),

          const SizedBox(height: 30),

          // 4. Action Buttons (Row for two buttons: Cancel and Logout)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel Button
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: context.theme.dividerColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'cancel'.tr,
                    style: context.textTheme.labelLarge,
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // Logout Button (Primary Action)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .redAccent, // Red for confirmation/destructive action
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _performLogout(context),
                  child: Text(
                    'logout'.tr,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
