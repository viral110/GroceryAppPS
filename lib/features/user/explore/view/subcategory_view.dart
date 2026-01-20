import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/explore/controller/sub_category_controller.dart';
import 'package:online_groceries_app/features/user/explore/widget/sub_category_filter_sheet.dart';
import 'package:online_groceries_app/features/user/home/view/home_view.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

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
            child: GestureDetector(
              onTap: () {
                // ✅ Use SubcategoryFilterBottomSheet (same design as FilterBottomSheet)
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
              child: SvgPicture.asset("assets/svg/filtter_icon.svg"),
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
                  // ✅ Show clear filters button if filters are active
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

            // GridView.builder(
            //   itemCount: controller.products.length,
            //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //     crossAxisSpacing: 14,
            //     mainAxisSpacing: 14,
            //     childAspectRatio: 0.68,
            //   ),
            //   itemBuilder: (context, index) {
            //     final item = controller.products[index];

            //     final storeConfig = item.storeConfigs.firstWhereOrNull(
            //       (s) => s.storeId == UserService.getUserFromHive().storeId,
            //     );

            //     final PackagingModel? userPackaging = storeConfig?.packaging
            //         .firstWhereOrNull((p) => p.isDefault);
            //     final int quantity = userPackaging?.quantity ?? 0;
            //     final bool isSoldOut = quantity <= 0;

            //     final double mrp = userPackaging?.price ?? 0.0;
            //     final int discount = userPackaging?.discount ?? 0;

            //     final double sellingPrice = discount > 0
            //         ? mrp - (mrp * discount / 100)
            //         : mrp;

            //     return GestureDetector(
            //       onTap: () {
            //         Get.to(() => ProductDetailView(product: item));
            //       },
            //       child: Container(
            //         padding: const EdgeInsets.all(10),
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(16),
            //           border: Border.all(color: Colors.grey.shade300),
            //         ),
            //         child: IntrinsicHeight(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               /// IMAGE
            //               Stack(
            //                 children: [
            //                   Align(
            //                     alignment: Alignment.center,
            //                     child: ClipRRect(
            //                       borderRadius: BorderRadius.circular(12),
            //                       child: Image.network(
            //                         item.thumbnail,
            //                         fit: BoxFit.contain,
            //                         height: 85.h,
            //                         width: 85.h,
            //                         errorBuilder: (context, error, stackTrace) {
            //                           return Container(
            //                             height: 85.h,
            //                             width: 85.h,
            //                             decoration: BoxDecoration(
            //                               color: Colors.grey.shade200,
            //                               borderRadius: BorderRadius.circular(
            //                                 12,
            //                               ),
            //                             ),
            //                             child: Icon(
            //                               Icons.shopping_bag_outlined,
            //                               size: 35,
            //                               color: Colors.grey.shade400,
            //                             ),
            //                           );
            //                         },
            //                         loadingBuilder: (context, child, loadingProgress) {
            //                           if (loadingProgress == null) return child;
            //                           return Container(
            //                             height: 85.h,
            //                             width: 85.h,
            //                             child: Center(
            //                               child: CircularProgressIndicator(
            //                                 strokeWidth: 2,
            //                                 value:
            //                                     loadingProgress
            //                                             .expectedTotalBytes !=
            //                                         null
            //                                     ? loadingProgress
            //                                               .cumulativeBytesLoaded /
            //                                           loadingProgress
            //                                               .expectedTotalBytes!
            //                                     : null,
            //                               ),
            //                             ),
            //                           );
            //                         },
            //                       ),
            //                     ),
            //                   ),

            //                   if (isSoldOut)
            //                     Positioned(
            //                       top: 4,
            //                       left: 4,
            //                       child: Container(
            //                         padding: const EdgeInsets.symmetric(
            //                           horizontal: 6,
            //                           vertical: 3,
            //                         ),
            //                         decoration: BoxDecoration(
            //                           color: Colors.red,
            //                           borderRadius: BorderRadius.circular(6),
            //                         ),
            //                         child: Text(
            //                           "SOLD OUT",
            //                           style: TextStyle(
            //                             color: Colors.white,
            //                             fontSize: 8.sp,
            //                             fontWeight: FontWeight.bold,
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                 ],
            //               ),

            //               const SizedBox(height: 6),

            //               /// TITLE
            //               SizedBox(
            //                 height: 36.h,
            //                 child: Text(
            //                   item.name,
            //                   maxLines: 2,
            //                   overflow: TextOverflow.ellipsis,
            //                   style: TextStyle(
            //                     color: AppColors.textColor,
            //                     fontWeight: FontWeight.w800,
            //                     fontSize: 14.sp,
            //                     height: 1.2,
            //                   ),
            //                 ),
            //               ),

            //               const SizedBox(height: 2),

            //               /// SUBTITLE
            //               Text(
            //                 userPackaging?.label ?? "-",
            //                 maxLines: 1,
            //                 overflow: TextOverflow.ellipsis,
            //                 style: TextStyle(
            //                   color: Colors.grey,
            //                   fontSize: 12.sp,
            //                 ),
            //               ),

            //               const Spacer(),

            //               const SizedBox(height: 6),

            //               /// PRICE + ADD BUTTON
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 crossAxisAlignment: CrossAxisAlignment.end,
            //                 children: [
            //                   Expanded(
            //                     child: Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       mainAxisSize: MainAxisSize.min,
            //                       children: [
            //                         Text(
            //                           "${AppConstantStrings.rupeeSymbol}${sellingPrice.toStringAsFixed(2)}",
            //                           style: TextStyle(
            //                             fontWeight: FontWeight.w600,
            //                             fontSize: 16.sp,
            //                           ),
            //                           maxLines: 1,
            //                           overflow: TextOverflow.ellipsis,
            //                         ),

            //                         if (discount > 0)
            //                           Text(
            //                             "${AppConstantStrings.rupeeSymbol}${mrp.toStringAsFixed(2)}",
            //                             style: TextStyle(
            //                               fontWeight: FontWeight.w400,
            //                               fontSize: 11.sp,
            //                               color: Colors.grey.shade600,
            //                               decoration:
            //                                   TextDecoration.lineThrough,
            //                             ),
            //                             maxLines: 1,
            //                             overflow: TextOverflow.ellipsis,
            //                           ),
            //                       ],
            //                     ),
            //                   ),

            //                   const SizedBox(width: 4),

            //                   GestureDetector(
            //                     onTap: isSoldOut
            //                         ? () {
            //                             Get.to(
            //                               () =>
            //                                   ProductDetailView(product: item),
            //                             );
            //                           }
            //                         : () async {
            //                             log("Clicked");
            //                             Get.back(closeOverlays: true);
            //                             CommonLoader.show();
            //                             final homeController =
            //                                 Get.find<HomeController>();
            //                             await homeController.addProductToCart(
            //                               item,
            //                               UserService.getUserFromHive().storeId,
            //                             );
            //                             Get.find<BottomNavController>()
            //                                 .changeTab(2);
            //                             CommonLoader.hide();
            //                           },
            //                     child: Container(
            //                       height: 38.h,
            //                       width: 38.h,
            //                       decoration: BoxDecoration(
            //                         color: AppColors.primary,
            //                         borderRadius: BorderRadius.circular(13),
            //                       ),
            //                       child: const Icon(
            //                         Icons.add,
            //                         color: Colors.white,
            //                         size: 16,
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // ),
          );
        }),
      ),
    );
  }
}
