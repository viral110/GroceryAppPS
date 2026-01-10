import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminAboutAppView extends StatelessWidget {
  const AdminAboutAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAboutAppController());

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: const CommonAppBar(title: "About App"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// APP INFO
              _sectionCard(
                title: "App Information",
                child: Column(
                  children: [
                    CommonTextField(
                      label: "App Name",
                      hint: "Enter app name",
                      controller: controller.appNameController,

                    ),
                    SizedBox(height: 16.h),

                    CommonTextField(
                      label: "App Version",
                      hint: "Enter app version",
                      controller: controller.versionController,

                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// ABOUT CONTENT
              _sectionCard(
                title: "About Content",
                child: CommonTextField(
                  label: "Description",
                  hint: "Enter about app content",
                  maxLines: 5,
                  controller: controller.descriptionController,
                ),
              ),

              SizedBox(height: 32.h),

              /// SAVE BUTTON
              SizedBox(
                width: 220.w,
                child: CommonButton(
                  title: "Save",
                  onTap: controller.saveAboutApp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- SECTION CARD ----------------
  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }
}

class AdminAboutAppController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// CONTROLLERS
  final appNameController = TextEditingController();
  final versionController = TextEditingController();
  final descriptionController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAboutApp();
  }

  /// FETCH EXISTING DATA
  Future<void> fetchAboutApp() async {
    final doc =
    await _firestore.collection("app_info").doc("about").get();

    if (doc.exists) {
      final data = doc.data()!;
      appNameController.text = data['app_name'] ?? '';
      versionController.text = data['version'] ?? '';
      descriptionController.text = data['description'] ?? '';
    }
  }

  /// SAVE / UPDATE DATA
  Future<void> saveAboutApp() async {
    if (appNameController.text.trim().isEmpty) {
      CommonToast.show("Please enter app name",type: ToastType.warning);
      return;
    }

    if (versionController.text.trim().isEmpty) {
      CommonToast.show("Please enter app version",type: ToastType.warning);
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      CommonToast.show("Please enter description",type: ToastType.warning);
      return;
    }

    isLoading.value = true;

    await _firestore.collection("app_info").doc("about").set(
      {
        "app_name": appNameController.text.trim(),
        "version": versionController.text.trim(),
        "description": descriptionController.text.trim(),
        "updated_at": Timestamp.now(),
      },
      SetOptions(merge: true), // 🔥 update-safe
    );

    isLoading.value = false;

    CommonToast.show("About App updated successfully",type: ToastType.success);
  }

  @override
  void onClose() {
    appNameController.dispose();
    versionController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
