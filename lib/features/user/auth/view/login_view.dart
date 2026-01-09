import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/user/auth/controller/login_controller.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    final controller =Get.put(LoginController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: Get.height,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/png/auth_bg.png"),fit: BoxFit.cover)
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(
              ()=> Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SizedBox(height: 60.h),

                  Center(
                    child: SvgPicture.asset(
                      'assets/svg/logo_2.svg',
                      height: 50.h,
                    ),
                  ),

                   SizedBox(height: 100.h),

                  /// Title
                   Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                   Text(
                    "Enter your emails and password",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.grayTextColor,
                    ),
                  ),

                  const SizedBox(height: 32),


                        CommonTextField(
                        label: "Email",
              hint: "Enter your email",
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 24),

                        CommonTextField(
              label: "Password",
              maxLines: 1,
              controller: controller.passwordController,
              isPassword: true,
              hint: 'Enter your password',
              obscureText: !controller.isPasswordVisible.value,
              onToggle: () {
                setState(() {
                  controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
                });
              },
                        ),


                        const SizedBox(height: 8),

                  /// Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child:  Text(
                        "Forgot Password?",
                        style: TextStyle(color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                          fontSize: 14.sp
                        ),
                      ),
                    ),
                  ),

                   SizedBox(height: 24.h),

                  /// Login Button
                CommonButton(title: "Log In", onTap: () {
                  Get.to(()=>MainScreen());
                },),
                  // Text("Gesture",),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
