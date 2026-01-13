import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/explore/controller/sub_category_controller.dart';
import 'package:online_groceries_app/features/user/home/controller/home_controller.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

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
              final double sellingPrice = item.price;

              final double originalPrice = item.discount > 0
                  ? sellingPrice / (1 - item.discount / 100)
                  : sellingPrice;
              // final discountedPrice =
              //     item.price - (item.price * item.discount / 100);
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// SUBTITLE
                      Text(
                        item.priceUnit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),

                      const SizedBox(height: 10),

                      /// PRICE + ADD BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Discounted Price
                              Text(
                                // "${AppConstantStrings.rupeeSymbol} ${discountedPrice.toStringAsFixed(2)}",
                                "${AppConstantStrings.rupeeSymbol} ${sellingPrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                ),
                              ),

                              // Original Price (only if discount exists)
                              if (item.discount > 0)
                                Text(
                                  "${AppConstantStrings.rupeeSymbol} ${originalPrice.toStringAsFixed(2)}",
                                  // "${AppConstantStrings.rupeeSymbol} ${item.price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),

                          GestureDetector(
                            onTap: () async {
                              log("Clicked");
                              final homeController = Get.find<HomeController>();
                              await homeController.addProductToCart(item);
                              Get.back(closeOverlays: true);
                              Get.find<BottomNavController>().changeTab(2);
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
