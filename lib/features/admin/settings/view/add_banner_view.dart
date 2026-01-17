import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/admin/settings/controller/add_banner_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminBannerView extends StatelessWidget {
  const AdminBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminBannerController());

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
                    GestureDetector(
                      onTap: controller.pickBannerImage,
                      child: Obx(
                            () => Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            image: controller.bannerBytes.value != null
                                ? DecorationImage(
                              image: MemoryImage(controller.bannerBytes.value!),
                              fit: BoxFit.cover,
                            )
                                : controller.bannerFile.value != null
                                ? DecorationImage(
                              image: FileImage(controller.bannerFile.value!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: controller.bannerBytes.value == null &&
                              controller.bannerFile.value == null
                              ? const Icon(Icons.image_outlined, size: 40)
                              : null,
                        ),
                      ),
                    ),


                    SizedBox(height: 20.h),

                    /// BANNER TITLE (OPTIONAL)
                    CommonTextField(
                      label: "Banner Title (Optional)",
                      hint: "Enter banner title",
                      controller: controller.titleController,
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: 180.w,
                      child: CommonButton(
                        title: "Add Banner",
                        onTap: controller.addBanner,
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

              Obx(
                    () => ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.banners.length,
                  onReorder: controller.reorderBanner,
                  itemBuilder: (context, index) {
                    final banner = controller.banners[index];
                    return Container(
                      key: ValueKey(banner.id),
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(14.w),
                      decoration: _cardDecoration(),
                      child: Row(
                        children: [
                          /// INDEX NUMBER
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          SizedBox(width: 12.w),

                          /// IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              banner.image,
                              height: 50,
                              width: 90,
                              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          /// TITLE
                          Expanded(
                            child: Text(
                              banner.title.isEmpty
                                  ? "Banner ${index + 1}"
                                  : banner.title,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteBanner(banner),
                          ),

                          SizedBox(width: 30.w),
                        ],
                      ),
                    );
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
