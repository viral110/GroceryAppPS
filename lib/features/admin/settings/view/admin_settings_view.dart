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






class AdminFeedbacksView extends StatelessWidget {
  const AdminFeedbacksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: const CommonAppBar(title: "User Feedbacks"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _feedbackCard(
                name: "Amit Patel",
                rating: 5,
                message: "Very good quality products and fast delivery.",
                date: "12 Jan 2026",
              ),
              _feedbackCard(
                name: "Neha Verma",
                rating: 4,
                message: "App is easy to use. Prices are reasonable.",
                date: "10 Jan 2026",
              ),
              _feedbackCard(
                name: "Rahul Shah",
                rating: 3,
                message: "Delivery was a bit late but products were fine.",
                date: "08 Jan 2026",
              ),
              _feedbackCard(
                name: "Priya Mehta",
                rating: 5,
                message: "Excellent service! Highly recommended.",
                date: "05 Jan 2026",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- FEEDBACK CARD ----------------
  Widget _feedbackCard({
    required String name,
    required int rating,
    required String message,
    required String date,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// USER NAME & DATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.grayTextColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          /// RATING
          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                Icons.star,
                size: 18,
                color: index < rating
                    ? Colors.amber
                    : Colors.grey.shade300,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          /// MESSAGE
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grayTextColor,
            ),
          ),
        ],
      ),
    );
  }
}


