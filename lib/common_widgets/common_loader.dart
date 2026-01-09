import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class CommonLoader {
  static bool _isShowing = false;

  static void show({String message = "Please wait..."}) {
    if (_isShowing) return;

    _isShowing = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      useSafeArea: false,
    );
  }

  static void hide() {
    if (!_isShowing) return;

    _isShowing = false;

    if (Get.isDialogOpen == true) {
      // ✅ Safely close ONLY the dialog
      Navigator.of(
        Get.overlayContext!,
        rootNavigator: true,
      ).pop();
    }
  }
}
