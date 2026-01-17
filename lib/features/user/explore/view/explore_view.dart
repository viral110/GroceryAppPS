import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/explore/controller/explore_controller.dart';
import 'package:online_groceries_app/features/user/explore/filter_bottom_sheet.dart';
import 'package:online_groceries_app/features/user/explore/view/subcategory_view.dart';
import 'package:online_groceries_app/features/user/home/controller/home_controller.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';
import 'package:online_groceries_app/services/user_services.dart';
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
                      hintText: "Search products/category",
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
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, index) {
                      final item = controller.searchedProducts[index];
                      final storeConfig = item.storeConfigs
                          .firstWhereOrNull((s) => s.storeId == UserService.getUserFromHive().storeId);

                      final PackagingModel? userPackaging = storeConfig?.packaging
                          .firstWhereOrNull((p) => p.isDefault);

                      final int quantity = userPackaging?.quantity ?? 0;
                      final bool isSoldOut = quantity <= 0;
                      final double mrp = userPackaging?.price ?? 0.0;
                      final int discount = userPackaging?.discount ?? 0;
                      /// ✅ DISCOUNTED PRICE (MINUS)
                      final double sellingPrice = discount > 0
                          ? mrp - (mrp * discount / 100)
                          : mrp;
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ProductDetailView(product: item));
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
                              Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item.thumbnail,
                                        fit: BoxFit.contain,
                                        height: 100.h,
                                        width: 100.h,
                                      ),
                                    ),
                                  ),

                                  if (isSoldOut)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "SOLD OUT",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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

                              Text(
                                userPackaging?.label ?? "-",
                                style: const TextStyle(color: Color(0xff7C7C7C)),
                              ),


                              const SizedBox(height: 10),

                              /// PRICE + ADD BUTTON
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "₹${sellingPrice.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.sp,
                                          color:
                                          isSoldOut ? Colors.grey : Colors.black,
                                        ),
                                      ),

                                      if (discount > 0)
                                        Text(
                                          "₹${mrp.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey,
                                            decoration:
                                            TextDecoration.lineThrough,
                                          ),
                                        ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: isSoldOut
                                        ? (){
                                      Get.to(() => ProductDetailView(product: item));
                                    }
                                        :() async {
                                      final homeController =
                                      Get.find<HomeController>();
                                      await homeController.addProductToCart(
                                        item,
                                        UserService.getUserFromHive().storeId,
                                      );

                                      Get.find<BottomNavController>()
                                          .changeTab(2);
                                    },
                                    child: Container(
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
