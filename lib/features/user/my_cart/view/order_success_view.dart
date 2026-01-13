import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/order_controller.dart';
import 'package:online_groceries_app/features/user/my_orders/view/order_details_view.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/png/success_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 115.h),
            Align(
              alignment: Alignment(-0.32, 0),

              child: Image.asset(
                "assets/png/success_image.png",
                height: 240.h,
                width: 270.w,
              ),
            ),
            SizedBox(height: 66.h),

            Text(
              "Your Order has been\naccepted",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20.sp),
            Text(
              "Your items has been placcd and is on\nit's way to being processed",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: AppColors.grayTextColor),
            ),
            SizedBox(height: 134.h),
            CommonButton(
              title: "Track Order",
              onTap: () {
                final order = orderController.lastOrder.value;
                log("Last Order: ${orderController.lastOrder.value}");

                if (order == null) {
                  CommonToast.show("Order not found", type: ToastType.error);
                  return;
                }
                Get.to(() => OrderDetailsView(order: order));
              },
              margin: EdgeInsets.symmetric(horizontal: 20),
            ),
            CommonButton(
              margin: EdgeInsets.symmetric(horizontal: 20),

              title: "Back to home",
              onTap: () {
                Get.find<BottomNavController>().currentIndex.value = 0;
                Get.to(() => MainScreen());
                // Get.back(closeOverlays: true);
                // Get.find<BottomNavController>().changeTab(0);
              },
              backgroundColor: Colors.transparent,
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderFailedDialog extends StatelessWidget {
  const OrderFailedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// CLOSE ICON
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ),

            const SizedBox(height: 10),

            /// IMAGE
            Container(
              height: 120,
              width: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffEAF7EF),
              ),
              child: Center(
                child: Image.asset(
                  "assets/png/failed_order_image.png", // add your image
                  height: 80,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            const Text(
              "Oops! Order Failed",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            /// SUBTITLE
            const Text(
              "Something went terribly wrong.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 60.h),

            /// TRY AGAIN BUTTON
            CommonButton(
              title: "Please Try Again",
              onTap: () {
                Get.back(closeOverlays: true);
              },
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Get.back(closeOverlays: true);
                Get.find<BottomNavController>().changeTab(0);
                // navigate to home
              },
              child: Text(
                "Back to home",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
