import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/favourite/controller/favourite_controller.dart';
import 'package:online_groceries_app/features/user/home/view/home_view.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/product_pricing_extension.dart';

class FavouriteView extends StatefulWidget {
  const FavouriteView({super.key});

  @override
  State<FavouriteView> createState() => _FavouriteViewState();
}

class _FavouriteViewState extends State<FavouriteView> {
  final controller = Get.put(FavouriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "Favourite", showBack: false),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final favItems = controller.favouriteProducts;

              // ✅ Show loading indicator while initially loading
              if (controller.isLoading.value) {
                return const SizedBox.shrink();
              }

              // ✅ Show empty state if no favourites
              if (favItems.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
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
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favItems.length,
                separatorBuilder: (_, __) => const Divider(height: 38),
                itemBuilder: (context, index) {
                  final item = favItems[index];
                  final storeConfig = item.storeConfigs.firstWhereOrNull(
                    (s) => s.storeId == UserService.getUserFromHive().storeId,
                  );

                  final PackagingModel? userPackaging = storeConfig?.packaging
                      .firstWhereOrNull((p) => p.isDefault);

                  final double mrp = userPackaging?.price ?? 0.0;
                  final int discount = userPackaging?.discount ?? 0;

                  final double sellingPrice = discount > 0
                      ? mrp - (mrp * discount / 100)
                      : mrp;

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => ProductDetailView(product: item));
                    },
                    child: Row(
                      children: [
                        // ✅ Product Image with better error handling
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.thumbnail,
                            height: 64.h,
                            width: 64.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 64.h,
                                width: 64.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 32,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 64.h,
                                width: 64.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        // ✅ Product Details
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
                                userPackaging?.label ?? "-",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ✅ Price
                        Text(
                          "₹${sellingPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // ✅ Add All To Cart Button with loading state
          Obx(() {
            if (controller.favouriteProducts.isEmpty) {
              return const SizedBox();
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: CommonButton(
                title: controller.isLoading.value
                    ? "Adding to Cart..."
                    : "Add All To Cart",
                onTap: controller.isLoading.value
                    ? () {} // Disable when loading
                    : controller.addAllToCart,
              ),
            );
          }),
        ],
      ),
    );
  }
}
