import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/user/about/view/about_view.dart';
import 'package:online_groceries_app/features/user/auth/view/login_view.dart';
import 'package:online_groceries_app/features/user/my_orders/view/my_order_view.dart';
import 'package:online_groceries_app/features/user/notifications/view/notification_view.dart';
import 'package:online_groceries_app/features/user/promo_code/view/promo_code_view.dart';
import 'package:online_groceries_app/services/auth_services.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

import '../../help/view/help_view.dart';
import '../../my_details/view/my_details_view.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => MyDetailsView());
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        "${UserService.getUserFromHive().firstName?[0]}${UserService.getUserFromHive().lastName?[0]}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${UserService.getUserFromHive().firstName} ${UserService.getUserFromHive().lastName}",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${UserService.getUserFromHive().email}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.grayTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            /// Menu Items
            Expanded(
              child: ListView(
                children: [
                  _menuItem(Icons.shopping_bag_outlined, "Orders", () {
                    Get.to(() => MyOrdersView());
                  }),
                  _menuItem(Icons.person_outline, "My Details", () {
                    Get.to(() => MyDetailsView());
                  }),
                  _menuItem(Icons.card_giftcard, "Promo Code", () {
                    Get.to(() => PromoCodeView());
                  }),
                  _menuItem(Icons.notifications_none, "Notifications", () {
                    Get.to(() => NotificationsView(userId: UserService.getUserFromHive().uid,));
                  }),
                  _menuItem(Icons.help_outline, "Help", () {
                    Get.to(() => HelpView());
                  }),
                  _menuItem(Icons.info_outline, "About", () {
                    Get.to(() => AboutView());
                  }),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    CommonLoader.show();
                    await AuthServices().signOut();
                    CommonLoader.hide();
                    Get.offAll(() => LoginScreen());
                  },
                  icon: Align(
                    child: Icon(Icons.logout, color: AppColors.whiteColor),
                  ),
                  iconAlignment: IconAlignment.start,

                  label: Text(
                    "Log Out",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, void Function()? onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.textColor),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        Divider(height: 1, color: Color(0xffE2E2E2)),
      ],
    );
  }

  void showComingSoonPopup() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              Text(
                "Coming Soon",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),

              const SizedBox(height: 8),

              /// DESCRIPTION
              Text(
                "This feature is under development and will be available soon.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTON
              CommonButton(title: "Okay", onTap: () => Get.back()),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
