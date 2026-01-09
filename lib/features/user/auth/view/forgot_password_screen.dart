import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/user/auth/controller/forgot_password_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40.h),

            Text(
              "Reset your password",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Text(
              "Enter your email and we’ll send you a reset link",
              style: TextStyle(fontSize: 14.sp, color: AppColors.grayTextColor),
            ),

            const SizedBox(height: 32),

            CommonTextField(
              label: "Email",
              hint: "Enter your email",
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 32.h),

            CommonButton(
              title: "Send Reset Link",
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await controller.sendResetLink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
