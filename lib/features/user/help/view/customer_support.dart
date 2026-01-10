import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/help/controller/customer_support_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class CustomerSupport extends StatelessWidget {
  const CustomerSupport({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerSupportController());

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: const CommonAppBar(title: "Customer Support"),
      body: Obx(() {
        if (controller.isNoData.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.support_agent,
                  size: 48,
                  color: AppColors.grayTextColor,
                ),
                SizedBox(height: 12),
                Text(
                  "Support information not available",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayTextColor,
                  ),
                ),
              ],
            ),
          );
        }

        final support = controller.support.value;

        if (support == null) {
          return const SizedBox();
        }

        // ✅ DATA UI
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _supportCard(
                icon: Icons.email_outlined,
                title: "Support Email",
                value: support.email,
              ),
              SizedBox(height: 16.h),
              _supportCard(
                icon: Icons.phone_outlined,
                title: "Support Phone",
                value: support.phone,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grayTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
