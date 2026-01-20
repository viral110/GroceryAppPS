import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/user/explore/controller/sub_category_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class SubcategoryFilterBottomSheet extends StatelessWidget {
  const SubcategoryFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubcategoryController>();

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),

          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
              const Text(
                "Filters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: controller.clearFilters,
                child: const Text("Clear"),
              ),
            ],
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xffF2F3F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🏷 BRANDS (Only show if available)
                    Obx(() {
                      if (controller.availableBrands.isEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Brands",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ...controller.availableBrands
                              .map(
                                (brand) => Obx(
                                  () => _checkTile(
                                    title: brand,
                                    isChecked: controller.selectedBrands
                                        .contains(brand),
                                    onTap: () => controller.toggleBrand(brand),
                                  ),
                                ),
                              )
                              .toList(),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),

                    /// 🔃 SORT
                    Text(
                      "Sort By",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Obx(
                      () => Column(
                        children: [
                          _radioTile(
                            "Price: Low → High",
                            SortType.priceLowToHigh,
                            controller,
                          ),
                          _radioTile(
                            "Price: High → Low",
                            SortType.priceHighToLow,
                            controller,
                          ),
                          _radioTile(
                            "Name: A → Z",
                            SortType.nameAToZ,
                            controller,
                          ),
                          _radioTile(
                            "Name: Z → A",
                            SortType.nameZToA,
                            controller,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    CommonButton(title: "Apply Filter", onTap: Get.back),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radioTile(
    String title,
    SortType value,
    SubcategoryController controller,
  ) {
    return RadioListTile<SortType>(
      value: value,
      contentPadding: EdgeInsets.zero,
      groupValue: controller.selectedSort.value,
      onChanged: (val) {
        controller.selectedSort.value = val!;
        controller.applyFilters();
      },
      title: Text(title),
      activeColor: AppColors.primary,
    );
  }

  Widget _checkTile({
    required String title,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isChecked ? AppColors.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
