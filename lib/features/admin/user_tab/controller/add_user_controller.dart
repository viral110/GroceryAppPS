import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/models/user_model.dart';
import 'package:online_groceries_app/services/auth_services.dart';

class AddUserController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final credit = TextEditingController();
  final area = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final pincode = TextEditingController();

  final isLoading = false.obs;



  /// VALIDATION CHECK
  bool validateForm() {

    /// FIRST NAME
    if (firstName.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter first name",
        type: ToastType.warning,
      );
      return false;
    }

    /// LAST NAME
    if (lastName.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter last name",
        type: ToastType.warning,
      );
      return false;
    }

    /// MOBILE NUMBER
    if (mobile.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter mobile number",
        type: ToastType.warning,
      );
      return false;
    }
    if (!GetUtils.isNumericOnly(mobile.text) || mobile.text.length != 10) {
      CommonToast.show(
        "Enter a valid 10-digit mobile number",
        type: ToastType.warning,
      );
      return false;
    }

    /// EMAIL
    if (email.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter email",
        type: ToastType.warning,
      );
      return false;
    }
    if (!GetUtils.isEmail(email.text.trim())) {
      CommonToast.show(
        "Enter a valid email address",
        type: ToastType.warning,
      );
      return false;
    }

    /// PASSWORD
    if (password.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter password",
        type: ToastType.warning,
      );
      return false;
    }

    /// CREDIT
    if (credit.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter credit",
        type: ToastType.warning,
      );
      return false;
    }
    if (!GetUtils.isNumericOnly(credit.text)) {
      CommonToast.show(
        "Credit must be a number",
        type: ToastType.warning,
      );
      return false;
    }
    if (int.parse(credit.text) <= 0) {
      CommonToast.show(
        "Credit must be greater than 0",
        type: ToastType.warning,
      );
      return false;
    }
    /// AREA
    if (area.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter area",
        type: ToastType.warning,
      );
      return false;
    }

    /// CITY
    if (city.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter city",
        type: ToastType.warning,
      );
      return false;
    }

    /// STATE
    if (state.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter state",
        type: ToastType.warning,
      );
      return false;
    }

    /// PINCODE
    if (pincode.text.trim().isEmpty) {
      CommonToast.show(
        "Please enter pincode",
        type: ToastType.warning,
      );
      return false;
    }
    if (!GetUtils.isNumericOnly(pincode.text) || pincode.text.length != 6) {
      CommonToast.show(
        "Enter a valid 6-digit pincode",
        type: ToastType.warning,
      );
      return false;
    }

    return true;
  }

  /// SAVE ADMIN
  Future<void> saveUser() async {
    if (!validateForm()) return;

    try {
      CommonLoader.show();
      final user = UserModel(
       firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        mobileNumber: mobile.text.trim(),
        email: email.text.trim(),
        credit: int.parse(credit.text),
        area: area.text.trim(),
        state: state.text.trim(),
        isNotification: false,
        city: city.text.trim(),
        pincode:  pincode.text.trim(),
        createdAt: DateTime.now(),
        fcmToken: "",
        updateAt: DateTime.now(),
        isAdmin: false
      );

      final success = await AuthServices().addUser(
        password: password.text.trim(),
        user: user,
      );
      CommonLoader.hide();
      if (success) {
        Get.back();
        CommonToast.show("User added successfully",type: ToastType.success);
      }
    } catch (e) {
      CommonToast.show(e.toString(),type: ToastType.error);

    } finally {
    }
  }
}
