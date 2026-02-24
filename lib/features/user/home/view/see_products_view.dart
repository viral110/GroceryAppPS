import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/home/controller/see_product_controller.dart';
import 'package:online_groceries_app/features/user/home/view/home_view.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class SeeAllProductsView extends StatelessWidget {
  final SeeAllType type;
  final String title;

  const SeeAllProductsView({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final controller = Get.put(
      SeeAllProductsController(type),
      tag: type.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: title,
        actions: [
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
          SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.products.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: (controller.products.length / 2).ceil(),
          itemBuilder: (context, index) {
            final int firstIndex = index * 2;
            final int secondIndex = firstIndex + 1;

            final firstProduct = controller.products[firstIndex];
            final secondProduct = secondIndex < controller.products.length
                ? controller.products[secondIndex]
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// LEFT CARD
                    Expanded(child: ProductCard(product: firstProduct)),

                    const SizedBox(width: 14),

                    /// RIGHT CARD
                    Expanded(
                      child: secondProduct != null
                          ? ProductCard(product: secondProduct)
                          : const SizedBox(), // empty if odd count
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
