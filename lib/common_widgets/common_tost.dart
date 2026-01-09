import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

enum ToastType { success, error, warning, info }

class CommonToast {
  static void show(
      String message, {
        ToastType type = ToastType.info,
      }) {
    Color bgColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        bgColor = Colors.red;
        icon = Icons.error;
        break;
      case ToastType.warning:
        bgColor = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        bgColor = AppColors.primary;
        icon = Icons.info;
    }

    Get.snackbar(
      "",
      "",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      titleText: const SizedBox(),
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
