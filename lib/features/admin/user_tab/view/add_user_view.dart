import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_drop_down.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/admin/user_tab/controller/add_user_controller.dart';
import 'package:online_groceries_app/models/user_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminAddAdminView extends StatelessWidget {
  final UserModel? userToEdit; // ✅ Optional user for edit mode

  const AdminAddAdminView({super.key, this.userToEdit});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddUserController());

    // ✅ Initialize edit mode if user is provided
    if (userToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initializeForEdit(userToEdit!);
      });
    } else {
      controller.clearFields();
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CommonAppBar(
        title: userToEdit != null ? "Edit User" : "Add User",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Obx(
            () => Column(
              children: [
                /// BASIC DETAILS
                _sectionCard(
                  title: "Basic Details",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CommonTextField(
                              label: "First Name",
                              hint: "Enter first name",
                              controller: controller.firstName,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CommonTextField(
                              label: "Last Name",
                              hint: "Enter last name",
                              controller: controller.lastName,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.h),

                      Row(
                        children: [
                          Expanded(
                            child: CommonTextField(
                              label: "Mobile Number",
                              hint: "Enter mobile number",
                              keyboardType: TextInputType.phone,
                              controller: controller.mobile,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CommonTextField(
                              label: "Email",
                              hint: "Enter email",
                              keyboardType: TextInputType.emailAddress,
                              controller: controller.email,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.h),

                      /// ✅ BUSINESS NAME FIELD
                      CommonTextField(
                        label: "Business Name",
                        hint: "Enter business name",
                        controller: controller.businessName,
                      ),
                      SizedBox(height: 25.h),

                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => CommonDropdownField<String>(
                                label: "Store",
                                hint: "Select store",
                                value: controller.selectedStoreId.value.isEmpty
                                    ? null
                                    : controller.selectedStoreId.value,
                                items: controller.stores
                                    .map(
                                      (store) => DropdownMenuItem<String>(
                                        value: store.id,
                                        child: Text(
                                          "${store.name} • ${store.address}",
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    controller.selectedStoreId.value = v!,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CommonTextField(
                              label: "Credit",
                              hint: "Enter Credit",
                              keyboardType: TextInputType.number,
                              controller: controller.credit,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.h),

                      /// ✅ PASSWORD FIELD (only show for new user)
                      if (!controller.isEditMode.value)
                        CommonTextField(
                          label: "Password",
                          hint: "Enter password",
                          keyboardType: TextInputType.visiblePassword,
                          controller: controller.password,
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                /// ADDRESS DETAILS
                _sectionCard(
                  title: "Address Details",
                  child: Column(
                    children: [
                      CommonTextField(
                        label: "Area",
                        hint: "Enter area",
                        controller: controller.area,
                      ),
                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          Expanded(
                            child: CommonTextField(
                              label: "City",
                              hint: "Enter city",
                              controller: controller.city,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CommonTextField(
                              label: "State",
                              hint: "Enter state",
                              controller: controller.state,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CommonTextField(
                              label: "Pincode",
                              hint: "Enter pincode",
                              keyboardType: TextInputType.number,
                              controller: controller.pincode,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                /// ✅ SAVE/UPDATE BUTTON
                SizedBox(
                  width: 220.w,
                  child: CommonButton(
                    title: controller.isEditMode.value
                        ? "Update User"
                        : "Save User",
                    onTap: () {
                      controller.saveUser();
                    },
                  ),
                ),
              ],
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
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 18, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
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
