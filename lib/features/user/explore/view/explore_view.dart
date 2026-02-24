import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/explore/controller/explore_controller.dart';
import 'package:online_groceries_app/features/user/explore/filter_bottom_sheet.dart';
import 'package:online_groceries_app/features/user/explore/view/subcategory_view.dart';
import 'package:online_groceries_app/features/user/home/view/home_view.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExploreController());
    final cartController = Get.put(CartController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Find Products",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        // ✅ Cart Icon in AppBar
        actions: [
          GestureDetector(
            onTap: () {
              Get.find<BottomNavController>().changeTab(2);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 26,
                    color: Colors.black87,
                  ),
                ),
                Obx(() {
                  final itemCount = cartController.cartItems.length;
                  if (itemCount == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        itemCount > 99 ? '99+' : itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),

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
                  return ListView.builder(
                    itemCount: (controller.searchedProducts.length / 2).ceil(),
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final int first = index * 2;
                      final int second = first + 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ProductCard(
                                  product: controller.searchedProducts[first],
                                ),
                              ),

                              const SizedBox(width: 12),

                              if (second < controller.searchedProducts.length)
                                Expanded(
                                  child: ProductCard(
                                    product:
                                        controller.searchedProducts[second],
                                  ),
                                )
                              else
                                const Spacer(),
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
                          color: baseColor.shade50,
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
