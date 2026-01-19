import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/explore/controller/sub_category_controller.dart';
import 'package:online_groceries_app/features/user/home/controller/home_controller.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

import '../../../admin/products/models/produce_model.dart';

class SubcategoryView extends StatelessWidget {
  final CategoryModel category;

  const SubcategoryView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubcategoryController(category.id));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: "${category.name}",
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SvgPicture.asset("assets/svg/filtter_icon.svg"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.products.isEmpty) {
            return const Center(child: Text("No products found."));
          }
          if (controller.isLoading.value) {
            // Already showing CommonLoader, so return empty container
            return const SizedBox.shrink();
          }

          return GridView.builder(
            itemCount: controller.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final item = controller.products[index];

              final storeConfig = item.storeConfigs.firstWhereOrNull(
                (s) => s.storeId == UserService.getUserFromHive().storeId,
              );

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

                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100.h,
                                    width: 100.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 100.h,
                                        width: 100.h,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
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
                          ),

                          if (isSoldOut)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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

                      const SizedBox(height: 8),

                      /// TITLE
                      Flexible(
                        child: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),

                      const SizedBox(height: 2),

                      /// SUBTITLE
                      Text(
                        userPackaging?.label ?? "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),

                      const Spacer(),

                      /// PRICE + ADD BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Discounted Price
                                Text(
                                  // "${AppConstantStrings.rupeeSymbol} ${discountedPrice.toStringAsFixed(2)}",
                                  "${AppConstantStrings.rupeeSymbol} ${sellingPrice.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Original Price (only if discount exists)
                                if (userPackaging!.discount > 0)
                                  Text(
                                    "${AppConstantStrings.rupeeSymbol} ${mrp.toStringAsFixed(2)}",
                                    // "${AppConstantStrings.rupeeSymbol} ${item.price.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          GestureDetector(
                            onTap: isSoldOut
                                ? () {
                                    Get.to(
                                      () => ProductDetailView(product: item),
                                    );
                                  }
                                : () async {
                                    log("Clicked");

                                    Get.back(closeOverlays: true);
                                    CommonLoader.show();
                                    final homeController =
                                        Get.find<HomeController>();
                                    await homeController.addProductToCart(
                                      item,
                                      UserService.getUserFromHive().storeId,
                                    );
                                    Get.find<BottomNavController>().changeTab(
                                      2,
                                    );
                                    CommonLoader.hide();
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
        }),
      ),
    );
  }
}
