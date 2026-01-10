import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/services/user_services.dart';

class MyDetailsController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();

  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    final user = UserService.getUserFromHive();

    firstNameController.text = user.firstName ?? '';
    lastNameController.text = user.lastName ?? '';
    emailController.text = user.email ?? '';
    mobileController.text = user.mobileNumber ?? '';

    areaController.text = user.area ?? '';
    cityController.text = user.city ?? '';
    stateController.text = user.state ?? '';
    pincodeController.text = user.pincode ?? '';
  }

  Future<void> updateProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();

    CommonLoader.show();

    final user = UserService.getUserFromHive();

    user.firstName = firstNameController.text.trim();
    user.lastName = lastNameController.text.trim();
    user.area = areaController.text.trim();
    user.city = cityController.text.trim();
    user.state = stateController.text.trim();
    user.pincode = pincodeController.text.trim();

    await UserService().updateUser(user);

    CommonLoader.hide();

    Get.back(closeOverlays: true);
    CommonToast.show("Details updated successfully", type: ToastType.success);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    areaController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.onClose();
  }
}
