import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/admin/settings/controller/admin_home_section_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class ManageHomeSectionsView extends StatelessWidget {
  const ManageHomeSectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminHomeSectionController());

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CommonAppBar(title: "Home Section Titles"),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: _sectionCard(
          title: "Home Section Title",
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CommonTextField(
                    controller: controller.title1,
                    label: "Section 1 Title",
                    hint: "Exclusive Offer",
                  ),
                  SizedBox(height: 16.h),

                  CommonTextField(
                    controller: controller.title2,
                    label: "Section 2 Title",
                    hint: "Best Selling",
                  ),
                  SizedBox(height: 16.h),

                  CommonTextField(
                    controller: controller.title3,
                    label: "Section 3 Title",
                    hint: "Groceries",
                  ),

                  // const Spacer(),
                  SizedBox(height: 40),
                  Obx(
                    () => CommonButton(
                      title: controller.isSaving.value ? "Saving..." : "Save",
                      onTap: controller.isSaving.value
                          ? () {}
                          : () => controller.saveSections(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
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
        BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(0.05)),
      ],
    );
  }
}
