import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
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



class AdminBannerView extends StatelessWidget {
  const AdminBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: const CommonAppBar(title: "Manage Banners"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ADD BANNER
              _sectionCard(
                title: "Add Banner",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// IMAGE UPLOAD PLACEHOLDER
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Upload Banner Image",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.grayTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// BANNER TITLE (OPTIONAL)
                    CommonTextField(
                      label: "Banner Title (Optional)",
                      hint: "Enter banner title",
                      controller: TextEditingController(),
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: 180.w,
                      child: CommonButton(
                        title: "Add Banner",
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              /// BANNER LIST
              Text(
                "Banner List",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),

              SizedBox(height: 16.h),

              _bannerRow("Home Banner 1"),
              _bannerRow("Festival Offer"),
              _bannerRow("Discount Banner"),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- BANNER ROW ----------------
  Widget _bannerRow(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          /// IMAGE PREVIEW
          Container(
            height: 50,
            width: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, size: 22),
          ),

          SizedBox(width: 14.w),

          /// TITLE
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          /// DELETE (UI ONLY)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// ---------------- SECTION CARD ----------------
  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }
}
class AdminAboutAppView extends StatelessWidget {
  const AdminAboutAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: const CommonAppBar(title: "About App"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// APP INFO
              _sectionCard(
                title: "App Information",
                child: Column(
                  children: [
                    CommonTextField(
                      label: "App Name",
                      hint: "Enter app name",
                      controller: TextEditingController(),
                    ),
                    SizedBox(height: 16.h),

                    CommonTextField(
                      label: "App Version",
                      hint: "Enter app version",
                      controller: TextEditingController(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// ABOUT CONTENT
              _sectionCard(
                title: "About Content",
                child: CommonTextField(
                  label: "Description",
                  hint: "Enter about app content",
                  maxLines: 5,
                  controller: TextEditingController(),
                ),
              ),

              SizedBox(height: 32.h),

              /// SAVE BUTTON
              SizedBox(
                width: 220.w,
                child: CommonButton(
                  title: "Save",
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- SECTION CARD ----------------
  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
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


class AdminHelpManageView extends StatelessWidget {
  const AdminHelpManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: const CommonAppBar(title: "Help Management"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              /// CUSTOMER SUPPORT
              _sectionCard(
                title: "Customer Support",
                child: Column(
                  children: [
                    CommonTextField(
                      label: "Support Email",
                      hint: "Enter support email",
                      controller: TextEditingController(),
                    ),
                    SizedBox(height: 16.h),

                    CommonTextField(
                      label: "Support Phone",
                      hint: "Enter support phone number",
                      controller: TextEditingController(),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),
              

              SizedBox(height: 32.h),

              /// SAVE BUTTON
              SizedBox(
                width: 220.w,
                child: CommonButton(
                  title: "Save Changes",
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- FAQ ROW ----------------
  Widget _faqRow(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.grayTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- SECTION CARD ----------------
  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          color: Colors.black.withOpacity(0.05),
        ),
      ],
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
