import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class MyDetailsController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final gstNumber = TextEditingController();

  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }
  Future<void> loadUserData() async {
    try {
     final userId = UserService.getUserFromHive().uid;

      /// ✅ DELAY LOADER
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CommonLoader.show();
      });

      final doc = await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        firstNameController.text = data['first_name'] ?? '';
        lastNameController.text = data['last_name'] ?? '';
        emailController.text = data['email'] ?? '';
        mobileController.text = data['mobile_number'] ?? '';
        areaController.text = data['area'] ?? '';
        cityController.text = data['city'] ?? '';
        stateController.text = data['state'] ?? '';
        pincodeController.text = data['pincode'] ?? '';
        gstNumber.text = data['gst_number'] ?? '';
      }

      CommonLoader.hide();
    } catch (e,s) {
      print("EROOR:${e.toString()}");
      print("EROOR:${s}");
      CommonLoader.hide();

      /// ✅ DELAY TOAST
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CommonToast.show(
          "Failed to load data",
          type: ToastType.error,
        );
      });
    }
  }
  // void loadUserData() {
  //   final user = UserService.getUserFromHive();
  //
  //   firstNameController.text = user.firstName ?? '';
  //   lastNameController.text = user.lastName ?? '';
  //   emailController.text = user.email ?? '';
  //   mobileController.text = user.mobileNumber ?? '';
  //
  //   areaController.text = user.area ?? '';
  //   cityController.text = user.city ?? '';
  //   stateController.text = user.state ?? '';
  //   pincodeController.text = user.pincode ?? '';
  //   gstNumber.text = user.gstNumber ?? '';
  // }

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
    user.gstNumber = gstNumber.text.trim();

    await UserService().updateUser(user);

    CommonLoader.hide();

    Get.back(closeOverlays: true);
    CommonToast.show("Details updated successfully", type: ToastType.success);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    gstNumber.dispose();
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
