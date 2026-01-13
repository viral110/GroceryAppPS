import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/user/favourite/controller/favourite_controller.dart';
import 'package:online_groceries_app/features/user/home/view/home_view.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';
import 'package:online_groceries_app/utils/product_pricing_extension.dart';

class FavouriteView extends StatelessWidget {
  const FavouriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavouriteController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "Favourite", showBack: false),

      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final favItems = controller.favouriteProducts;
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              // Show empty state if no favourites
              if (controller.favouriteProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 100,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Favourites Yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start adding products to your favourites',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favItems.length,
                separatorBuilder: (_, __) => const Divider(height: 38),
                itemBuilder: (context, index) {
                  final item = favItems[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => ProductDetailView(product: item));
                    },
                    child: Row(
                      children: [
                        Image.network(item.thumbnail, height: 45),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // item.priceUnit,
                                item.defaultPackaging,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          // "₹${item.price.toStringAsFixed(2)}",
                          "₹${item.unitPriceFor(item.defaultPackaging).toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: CommonButton(
              title: "Add All To Cart ",
              onTap: controller.addAllToCart,
            ),
          ),
        ],
      ),
    );
  }
}
