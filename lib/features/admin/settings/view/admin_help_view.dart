import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminHelpManageView extends StatelessWidget {
  const AdminHelpManageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminHelpManageController());

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: const CommonAppBar(title: "Help Management"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              /// CUSTOMER SUPPORT
              _sectionCard(
                title: "Customer Support",
                child: Column(
                  children: [
                    CommonTextField(
                      label: "Support Email",
                      hint: "Enter support email",
                      controller: controller.emailController,

                    ),
                    SizedBox(height: 16.h),

                    CommonTextField(
                      label: "Support Phone",
                      hint: "Enter support phone number",
                      controller: controller.phoneController,

                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),



              SizedBox(height: 32.h),

              /// SAVE BUTTON
              Obx(
                    () => SizedBox(
                  width: 220.w,
                  child: CommonButton(
                    title: controller.isLoading.value
                        ? "Saving..."
                        : "Save Changes",
                    onTap: controller.isLoading.value
                        ? () {}
                        : controller.saveHelpInfo,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- FAQ ROW ----------------
  Widget _faqRow(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.grayTextColor,
            ),
          ),
        ],
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
      decoration: _cardDecoration(),
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }
}
class AdminHelpManageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// CONTROLLERS
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHelpInfo();
  }

  /// FETCH EXISTING DATA
  Future<void> fetchHelpInfo() async {
    final doc =
    await _firestore.collection("app_info").doc("support").get();
    if (doc.exists) {
      final data = doc.data()!;
      emailController.text = data['support_email'] ?? '';
      phoneController.text = data['support_phone'] ?? '';
    }
  }

  /// SAVE / UPDATE DATA
  Future<void> saveHelpInfo() async {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (email.isEmpty) {
      CommonToast.show("Please enter support email",type: ToastType.warning);
      return;
    }

    if (phone.isEmpty) {
      CommonToast.show("Please enter support phone number",type: ToastType.warning);
      return;
    }

    isLoading.value = true;

    await _firestore.collection("app_info").doc("support").set(
      {
        "support_email": email,
        "support_phone": phone,
        "updated_at": Timestamp.now(),
      },
      SetOptions(merge: true), // 🔥 safe update
    );

    isLoading.value = false;

    CommonToast.show("Help information updated successfully");
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
