import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

import '../../auth/view/login_view.dart' show LoginScreen;

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/png/welcome_bg.png"),fit: BoxFit.fill)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // SvgPicture.asset("assets/svg/logo_2.svg",color: AppColors.whiteColor,),
            // Text("Welcome\nto our store",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //   color: AppColors.whiteColor,
            //   fontWeight: FontWeight.w600,
            //   fontSize: 48.sp,
            // ),),
            //
            // Text("Ger your groceries in as fast as one hour",
            // style: TextStyle(
            //   fontSize: 16.sp,
            //   color: AppColors.whiteColor.withOpacity(0.7),
            // ),
            // ),
            SizedBox(height: 35.h,),
            CommonButton(title: "Get Started", onTap: (){
              Get.to(()=>LoginScreen());
            },margin: EdgeInsets.symmetric(horizontal: 30.w),),
            SizedBox(height: 90.h,),

          ],
        ),
      ),
    );
  }
}
