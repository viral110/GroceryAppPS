import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/models/user_model.dart';
import 'package:online_groceries_app/services/auth_services.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

import '../../store_manage/models/store_model.dart';

class AddUserController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final credit = TextEditingController();
  final businessName = TextEditingController(); // ✅ NEW FIELD
  final area = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final pincode = TextEditingController();

  final isLoading = false.obs;
  final isEditMode = false.obs; // ✅ Track if editing
  String? editingUserId; // ✅ Store user ID when editing

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final stores = <StoreModel>[].obs;
  final selectedStoreId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  /// ✅ INITIALIZE FOR EDIT MODE
  void initializeForEdit(UserModel user) {
    isEditMode.value = true;
    editingUserId = user.uid;

    firstName.text = user.firstName ?? '';
    lastName.text = user.lastName ?? '';
    mobile.text = user.mobileNumber ?? '';
    email.text = user.email ?? '';
    credit.text = user.credit.toString();
    businessName.text = user.businessName ?? ''; // ✅ Set business name
    area.text = user.area ?? '';
    city.text = user.city ?? '';
    state.text = user.state ?? '';
    pincode.text = user.pincode ?? '';
    selectedStoreId.value = user.storeId ?? '';
  }

  /// ✅ CLEAR ALL FIELDS
  void clearFields() {
    firstName.clear();
    lastName.clear();
    mobile.clear();
    email.clear();
    password.clear();
    credit.clear();
    businessName.clear();
    area.clear();
    city.clear();
    state.clear();
    pincode.clear();
    selectedStoreId.value = '';
    isEditMode.value = false;
    editingUserId = null;
  }

  Future<void> fetchStores() async {
    final snapshot = await _firestore
        .collection(AppConstantStrings.storesCollection)
        .orderBy('createdAt', descending: true)
        .get();

    stores.assignAll(
      snapshot.docs.map((doc) => StoreModel.fromJson(doc.id, doc.data())),
    );
  }

  StoreModel? get selectedStore {
    return stores.firstWhereOrNull((e) => e.id == selectedStoreId.value);
  }

  /// VALIDATION CHECK
  bool validateForm() {
    /// FIRST NAME
    if (firstName.text.trim().isEmpty) {
      CommonToast.show("Please enter first name", type: ToastType.warning);
      return false;
    }

    /// LAST NAME
    if (lastName.text.trim().isEmpty) {
      CommonToast.show("Please enter last name", type: ToastType.warning);
      return false;
    }

    /// MOBILE NUMBER
    if (mobile.text.trim().isEmpty) {
      CommonToast.show("Please enter mobile number", type: ToastType.warning);
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
      CommonToast.show("Please enter email", type: ToastType.warning);
      return false;
    }
    if (!GetUtils.isEmail(email.text.trim())) {
      CommonToast.show("Enter a valid email address", type: ToastType.warning);
      return false;
    }

    /// STORE
    if (selectedStoreId.value.isEmpty) {
      CommonToast.show("Please select a store", type: ToastType.warning);
      return false;
    }

    /// PASSWORD (only required for new user)
    if (!isEditMode.value && password.text.trim().isEmpty) {
      CommonToast.show("Please enter password", type: ToastType.warning);
      return false;
    }

    /// CREDIT
    if (credit.text.trim().isEmpty) {
      CommonToast.show("Please enter credit", type: ToastType.warning);
      return false;
    }
    if (!GetUtils.isNumericOnly(credit.text)) {
      CommonToast.show("Credit must be a number", type: ToastType.warning);
      return false;
    }
    if (int.parse(credit.text) < 0) {
      CommonToast.show("Credit cannot be negative", type: ToastType.warning);
      return false;
    }

    /// BUSINESS NAME
    if (businessName.text.trim().isEmpty) {
      CommonToast.show("Please enter business name", type: ToastType.warning);
      return false;
    }

    /// AREA
    if (area.text.trim().isEmpty) {
      CommonToast.show("Please enter area", type: ToastType.warning);
      return false;
    }

    /// CITY
    if (city.text.trim().isEmpty) {
      CommonToast.show("Please enter city", type: ToastType.warning);
      return false;
    }

    /// STATE
    if (state.text.trim().isEmpty) {
      CommonToast.show("Please enter state", type: ToastType.warning);
      return false;
    }

    /// PINCODE
    if (pincode.text.trim().isEmpty) {
      CommonToast.show("Please enter pincode", type: ToastType.warning);
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

  /// ✅ SAVE OR UPDATE USER
  Future<void> saveUser() async {
    if (!validateForm()) return;

    try {
      CommonLoader.show();

      if (isEditMode.value) {
        // UPDATE EXISTING USER
        await _updateUser();
      } else {
        // CREATE NEW USER
        await _createUser();
      }

      CommonLoader.hide();
    } catch (e) {
      CommonLoader.hide();
      CommonToast.show(e.toString(), type: ToastType.error);
    }
  }

  /// ✅ CREATE NEW USER
  Future<void> _createUser() async {
    final user = UserModel(
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      mobileNumber: mobile.text.trim(),
      email: email.text.trim(),
      credit: double.parse(credit.text),
      remainingCredits: double.parse(credit.text),
      businessName: businessName.text.trim(), // ✅ Add business name
      area: area.text.trim(),
      state: state.text.trim(),
      isNotification: false,
      city: city.text.trim(),
      pincode: pincode.text.trim(),
      createdAt: DateTime.now(),
      fcmToken: "",
      storeId: selectedStoreId.value,
      updateAt: DateTime.now(),
      isAdmin: false,
      isEnable: true,
    );

    final success = await AuthServices().addUser(
      password: password.text.trim(),
      user: user,
    );

    if (success) {
      Get.back();
      CommonToast.show("User added successfully", type: ToastType.success);
      clearFields();
    }
  }

  /// ✅ UPDATE EXISTING USER
  Future<void> _updateUser() async {
    if (editingUserId == null) {
      throw Exception("User ID not found");
    }

    // Get current user data to preserve certain fields
    final userDoc = await _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(editingUserId)
        .get();

    if (!userDoc.exists) {
      throw Exception("User not found");
    }

    final currentData = userDoc.data()!;
    final currentCredit = (currentData['credit'] ?? 0).toDouble();
    final currentRemainingCredits = (currentData['remaining_credits'] ?? 0)
        .toDouble();
    final newCredit = double.parse(credit.text);

    // Calculate credit difference
    final creditDifference = newCredit - currentCredit;

    // Update user data
    await _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(editingUserId)
        .update({
          'firstName': firstName.text.trim(),
          'lastName': lastName.text.trim(),
          'mobileNumber': mobile.text.trim(),
          'email': email.text.trim(),
          'credit': newCredit,
          'remaining_credits': currentRemainingCredits + creditDifference,
          'businessName': businessName.text.trim(), // ✅ Update business name
          'area': area.text.trim(),
          'city': city.text.trim(),
          'state': state.text.trim(),
          'pincode': pincode.text.trim(),
          'storeId': selectedStoreId.value,
          'updateAt': FieldValue.serverTimestamp(),
        });

    Get.back();
    CommonToast.show("User updated successfully", type: ToastType.success);
    clearFields();
  }

  /// ✅ DELETE USER
  Future<void> deleteUser(String userId) async {
    try {
      CommonLoader.show();

      // Check if user has any pending orders
      final ordersSnapshot = await _firestore
          .collection(AppConstantStrings.orderCollection)
          .where('user_id', isEqualTo: userId)
          .where('order_status', whereIn: ['Pending', 'Ongoing'])
          .get();

      if (ordersSnapshot.docs.isNotEmpty) {
        CommonLoader.hide();
        CommonToast.show(
          "Cannot delete user with pending/ongoing orders",
          type: ToastType.error,
        );
        return;
      }

      // Delete user
      await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(userId)
          .delete();

      CommonLoader.hide();
      CommonToast.show("User deleted successfully", type: ToastType.success);
      Get.back(); // Go back if on detail page
    } catch (e) {
      CommonLoader.hide();
      CommonToast.show(
        "Failed to delete user: ${e.toString()}",
        type: ToastType.error,
      );
    }
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    mobile.dispose();
    email.dispose();
    password.dispose();
    credit.dispose();
    businessName.dispose();
    area.dispose();
    city.dispose();
    state.dispose();
    pincode.dispose();
    super.onClose();
  }
}
