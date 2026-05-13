// ignore_for_file: unintended_html_in_doc_comment

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common_dialog.dart';
 

 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to show a snackbar after the dialog is closed
  void _showResultSnackbar(BuildContext context, bool? result) {
    final message = result == true
        ? 'Biometric Enabled!'
        : result == false
            ? 'Biometric Skipped.'
            : 'Dialog Dismissed.';

    showCommonDialog(
      title: result == true ? 'Success' : 'Info',
      message: message,
      isError: result == false || result == null, // Maybe treat skipped/dismissed as non-success or just info
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Dialog Demo'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.fingerprint),
          label: const Text('Check Biometric Status'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            // Show the custom dialog and wait for the result (true or false)
            final bool? enableResult = await showBiometricRequiredDialog(context);

            // Display the result using a SnackBar
            if (context.mounted) {
              _showResultSnackbar(context, enableResult);
            }
          },
        ),
      ),
    );
  }
}

// --- 2. Function to Display the Custom Modal and Return a Result ---

/// Shows the custom biometric requirement dialog.
/// Returns a Future<bool?> where:
/// - true: User clicked 'Enable'
/// - false: User clicked 'No'
/// - null: Dialog was dismissed (tapped outside or back button)
Future<bool?> showBiometricRequiredDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    // The barrierDismissible property handles null return value (user tapping outside)
    barrierDismissible: true, 
    builder: (BuildContext context) {
      // Use Dialog for custom shape and content
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 10,
        backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
        child: const BiometricRequiredContent(),
      );
    },
  );
}

// --- 3. The Custom Widget Containing the UI and Actions ---

class BiometricRequiredContent extends StatelessWidget {
  const BiometricRequiredContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Icon (Mimicking the Lottie Animation Spot)
          const Center(
            child: Icon(
              Icons.fingerprint_rounded,
              color: Colors.blue,
              size: 80,
            ),
          ),

          const SizedBox(height: 20),

          // 2. Title
          Text(
            'Enable Biometric Login',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // 3. Message/Content
          Text(
            'Biometric authentication is disabled. Enable it now for faster and secure access?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 30),

          // 4. Action Buttons (Row for "No" and "Enable")
          Row(
            children: [
              // 'No' Button (TextButton)
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Pop dialog with false, indicating user said no
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'No',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 'Enable' Button (ElevatedButton)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Primary button color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    // Pop dialog with true, indicating user wants to enable
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Enable',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
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