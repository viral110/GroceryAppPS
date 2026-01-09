import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/user/explore/controller/explore_controller.dart';
import 'package:online_groceries_app/features/user/explore/view/subcategory_view.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExploreController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "Find Products", showBack: false),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SEARCH BAR
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search Store",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      FilterBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                    );
                  },
                  child: SvgPicture.asset("assets/svg/filtter_icon.svg"),
                ),
                SizedBox(width: 15),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Obx(() {
                if (controller.isSearching) {
                  if (controller.searchedProducts.isEmpty) {
                    return const Center(child: Text("No products found."));
                  }

                  /// 🔍 SEARCH RESULT GRID
                  return GridView.builder(
                    itemCount: controller.searchedProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      final item = controller.searchedProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ProductDetailView());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// IMAGE
                              Expanded(
                                child: Center(
                                  child: Image.network(
                                    item.thumbnail,
                                    height: 90,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// TITLE
                              Text(
                                item.name,
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),

                              const SizedBox(height: 4),

                              /// SUBTITLE
                              Text(
                                // "180g, Price",
                                item.priceUnit,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// PRICE + ADD BUTTON
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${AppConstantStrings.rupeeSymbol} ${item.price}",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    height: 45.h,
                                    width: 45.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                if (controller.categories.isEmpty) {
                  return const Center(child: Text("No categories found."));
                }
                if (controller.isLoading.value) {
                  // Already showing CommonLoader, so return empty container
                  return const SizedBox.shrink();
                }

                /// 📦 CATEGORY GRID (DEFAULT)
                return GridView.builder(
                  itemCount: controller.categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final item = controller.categories[index];
                    final baseColor =
                        Colors.primaries[index % Colors.primaries.length];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => SubcategoryView(category: item));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: baseColor.shade50, //item.color,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: baseColor.shade400,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              item.imageUrl,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  FilterBottomSheet({super.key});

  final controller = Get.put(FilterController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40.h),

          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: const Icon(Icons.close, size: 25),
                ),
                const Text(
                  "Filters",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF2F3F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CATEGORIES
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _checkTile("Eggs", controller.eggs),
                        _checkTile("Noodles & Pasta", controller.noodles),
                        _checkTile("Chips & Crisps", controller.chips),
                        _checkTile("Fast Food", controller.fastFood),

                        const SizedBox(height: 20),

                        /// BRAND
                        Text(
                          "Brand",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _checkTile(
                          "Individual Collection",
                          controller.individual,
                        ),
                        _checkTile("Cocola", controller.cocola),
                        _checkTile("Ifad", controller.ifad),
                        _checkTile("Kazi Farmas", controller.kaziFarmas),
                      ],
                    ),
                  ),

                  CommonButton(
                    title: "Apply Filter",
                    onTap: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CHECKBOX TILE (UNCHANGED LOGIC)
  Widget _checkTile(String title, RxBool value) {
    return Obx(() {
      final isChecked = value.value;

      return InkWell(
        onTap: () => value.value = !isChecked,
        borderRadius: BorderRadius.circular(8),
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
    });
  }
}

class FilterController extends GetxController {
  RxBool eggs = true.obs;
  RxBool noodles = false.obs;
  RxBool chips = false.obs;
  RxBool fastFood = false.obs;

  // Brands
  RxBool individual = false.obs;
  RxBool cocola = true.obs;
  RxBool ifad = false.obs;
  RxBool kaziFarmas = false.obs;
}
