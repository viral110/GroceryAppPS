import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/settings/view/add_banner_view.dart';
import 'package:online_groceries_app/features/admin/settings/view/admin_about_view.dart';
import 'package:online_groceries_app/features/admin/settings/view/admin_feedbacks_view.dart';
import 'package:online_groceries_app/features/admin/settings/view/admin_help_view.dart';
import 'package:online_groceries_app/features/admin/settings/view/manage_category.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Settings",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textColor,
          ),
        ),

        SizedBox(height: 20.h),

       Expanded(child: SingleChildScrollView(
         child: Column(
           children: [
             _settingItem(
               title: "Categories",
               subtitle: "Manage category name & image",
               onTap: () => Get.to(() =>AdminManageCategoryView()),
             ),

             _settingItem(
               title: "Banner",
               subtitle: "Manage home banner",
               onTap: () => Get.to(() => const AdminBannerView()),
             ),

             _settingItem(
               title: "About Us",
               subtitle: "Edit about us content",
               onTap: () => Get.to(() => const AdminAboutAppView()),
             ),

             _settingItem(
               title: "Help",
               subtitle: "Manage help & support details",
               onTap: () => Get.to(() => const AdminHelpManageView()),
             ), _settingItem(
               title: "Feedbacks",
               subtitle: "View user feedback and ratings",
               onTap: () => Get.to(() => const AdminFeedbacksView()),
             ),
           ],
         ),
       ))
      ],
    );
  }

  Widget _settingItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.grayTextColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}








