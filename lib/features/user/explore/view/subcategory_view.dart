import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/explore/controller/sub_category_controller.dart';
import 'package:online_groceries_app/features/user/explore/widget/sub_category_filter_sheet.dart';
import 'package:online_groceries_app/features/user/home/view/home_view.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class SubcategoryView extends StatelessWidget {
  final CategoryModel category;

  const SubcategoryView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubcategoryController(category.id));
    final cartController = Get.put(CartController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          // ✅ Cart Icon
          GestureDetector(
            onTap: () {
              Get.back();
              Get.find<BottomNavController>().changeTab(2);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                    right: 4,
                    top: 0,
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

          // Filter Icon
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  const SubcategoryFilterBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset("assets/svg/filtter_icon.svg"),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const SizedBox.shrink();
          }

          if (controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No products found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (controller.selectedBrands.isNotEmpty ||
                      controller.selectedSort.value != SortType.none)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton(
                        onPressed: controller.clearFilters,
                        child: Text(
                          "Clear Filters",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return ClipRect(
            child: ListView.builder(
              itemCount: (controller.products.length / 2).ceil(),
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
                            product: controller.products[first],
                          ),
                        ),

                        const SizedBox(width: 12),

                        if (second < controller.products.length)
                          Expanded(
                            child: ProductCard(
                              product: controller.products[second],
                            ),
                          )
                        else
                          const Spacer(),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
