import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
import '../../../../services/auth_services.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      CommonToast.show("Please enter your email", type: ToastType.warning);
      return;
    }

    if (!_isEmailValid(email)) {
      CommonToast.show("Please enter a valid email", type: ToastType.warning);
      return;
    }

    CommonLoader.show();
    final exists = await isEmailRegistered(email);

    if (!exists) {
      CommonLoader.hide();
      CommonToast.show(
        "No account found with this email",
        type: ToastType.error,
      );
      return;
    }

    await AuthServices().sendPasswordResetEmail(email);

    CommonLoader.hide();

    await Future.delayed(const Duration(milliseconds: 400));

    CommonToast.show("Reset link sent", type: ToastType.success);

    Get.back(closeOverlays: true);
  }

  Future<bool> isEmailRegistered(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
