import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/admin/auth/controller/admin_login_controller.dart';
import 'package:online_groceries_app/features/admin/dashboard/view/admin_dashboard.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final controller =Get.put(AdminLoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Center(
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Admin Panel",
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColor,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                "Login to manage the application",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.grayTextColor,
                ),
              ),

              SizedBox(height: 32.h),

              CommonTextField(
                label: "Email",
                hint: "Admin email",
                controller: controller.emailController,
              ),

              SizedBox(height: 20.h),

              CommonTextField(
                label: "Password",
                controller: controller.passwordController,
                isPassword: true,
                hint: "Admin password",
                maxLines: 1,
                obscureText: !controller.isPasswordVisible.value,
                onToggle: () {
                  setState(() {
                    controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
                  });
                },
              ),

              SizedBox(height: 30.h),

            CommonButton(title: "Login", onTap: () {
            controller.loginWithEmailAndPassword();
            },)
            ],
          ),
        ),
      ),
    );
  }

}


