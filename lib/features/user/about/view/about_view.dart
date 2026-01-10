import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/about/controller/about_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutController());
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: CommonAppBar(title: "About"),
      body: Obx(() {
        // 🟡 NO DATA STATE
        if (controller.isNoData.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: AppColors.grayTextColor,
                ),
                SizedBox(height: 12),
                Text(
                  "No information available",
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

        final about = controller.about.value;
        if (about == null) {
          // Empty placeholder while loader is visible
          return const SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.shopping_cart,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                about.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                about.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.grayTextColor),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                "Version ${about.version}",
                style: TextStyle(fontSize: 13, color: AppColors.grayTextColor),
              ),
            ],
          ),
        );
      }),
    );
  }
}
