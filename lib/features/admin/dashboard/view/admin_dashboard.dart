import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/dashboard/controller/dashboard_controller.dart';
import 'package:online_groceries_app/features/admin/dashboard/view/dashboard_tab_view.dart';
import 'package:online_groceries_app/features/admin/orders/view/orders_view.dart';
import 'package:online_groceries_app/features/admin/products/view/products_view.dart';
import 'package:online_groceries_app/features/admin/settings/view/admin_settings_view.dart';
import 'package:online_groceries_app/features/admin/store_manage/view/store_manage_view.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/user_list_view.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 280.w,
            color: AppColors.whiteColor,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/svg/logo_2.svg",height: 37.h,),
                      SizedBox(width: 15.w,height: 15.h,),
                      Text(
                        "Admin Panel",
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                _sideItem(
                  "Dashboard",
                  AdminTab.dashboard,
                  controller,
                ),
                _sideItem(
                  "Users",
                  AdminTab.users,
                  controller,
                ),
                _sideItem(
                  "Orders",
                  AdminTab.orders,
                  controller,
                ),
                _sideItem(
                  "Products",
                  AdminTab.products,
                  controller,
                ),
                _sideItem(
                  "Store Manage",
                  AdminTab.store,
                  controller,
                ),
                _sideItem(
                  "Settings",
                  AdminTab.settings,
                  controller,
                ),

                // const Spacer(),

                // _logoutItem(),
              ],
            ),
          ),

          /// CONTENT AREA
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Obx(() {
                switch (controller.selectedTab.value) {
                  case AdminTab.dashboard:
                    return const DashboardTab();
                  case AdminTab.users:
                    return  UserListView();
                  case AdminTab.orders:
                    return const AdminOrdersView();
                  case AdminTab.products:
                    return  AdminProductsView();
                    case AdminTab.store:
                    return  StoreManageView();
                  case AdminTab.settings:
                    return const AdminSettingsView();
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// SIDEBAR ITEM
  Widget _sideItem(
      String title,
      AdminTab tab,
      AdminDashboardController controller,
      ) {
    return Obx(() {
      final isActive = controller.selectedTab.value == tab;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => controller.changeTab(tab),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color:
                    isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _logoutItem() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Get.offAllNamed('/admin-login');
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Text(
            "Logout",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
