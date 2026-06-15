import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/favourite/controller/favourite_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/features/user/product_detail/controller/product_detai_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class ProductDetailView extends StatefulWidget {
  final ProductModel product;
  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late final ProductDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProductDetailController(widget.product));
  }

  @override
  Widget build(BuildContext context) {
    final favouriteController = Get.put(FavouriteController());

    return Scaffold(
      body: Column(
        children: [
          /// ================= IMAGE SECTION =================
          Container(
            height: 413.h,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xffF2F3F2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: SafeArea(child: _buildImageSlider()),
          ),

          /// ================= DETAILS =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// TITLE
                      Expanded(
                        child: Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      /// FAVORITE ICON
                      Obx(() {
                        final isFav = favouriteController.isFavourite(
                          widget.product.id,
                        );
                        final isProcessing = favouriteController.isProcessing(
                          widget.product.id,
                        );

                        return GestureDetector(
                          onTap: isProcessing
                              ? null
                              : () => favouriteController.toggleFavourite(
                                  widget.product,
                                ),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: isProcessing
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFav ? Colors.red : Colors.grey,
                                    size: 28,
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// SELECTED PACKAGING
                  Obx(
                    () => Text(
                      "${controller.selectedPackaging.label}, Price",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ================= PACKAGING OPTIONS =================
                  Obx(() {
                    if (controller.sortedPackaging.isEmpty) {
                      return const SizedBox();
                    }

                    return Wrap(
                      spacing: 10,
                      children: List.generate(
                        controller.sortedPackaging.length,
                        (index) {
                          final isSelected =
                              controller.selectedWeightIndex.value == index;

                          return ChoiceChip(
                            label: Text(controller.sortedPackaging[index]),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (_) => controller.selectWeight(index),
                          );
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  /// ================= QTY + PRICE =================
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: controller.decrementQuantity,
                              child: _qtyButton(Icons.remove),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  controller.quantity.value.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: controller.incrementQuantity,
                              child: _qtyButton(Icons.add, isAdd: true),
                            ),
                          ],
                        ),

                        /// ✅ PRICE DISPLAY WITH DISCOUNT
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${controller.totalPrice.value.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            // Show MRP if there's a discount
                            if (controller.discount > 0)
                              Text(
                                "₹${(controller.unitPrice * controller.quantity.value).toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ✅ Show discount percentage if available
                  Obx(() {
                    if (controller.discount > 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "You save ₹${((controller.unitPrice - controller.sellingPrice) * controller.quantity.value).toStringAsFixed(2)} (${controller.discount}% OFF)",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // ✅ Stock availability indicator
                  Obx(() {
                    if (controller.isSoldOut) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Out of Stock",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    } else if (controller.isLowStock) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Only ${controller.availableStock} left in stock",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const Divider(height: 32),

                  /// ================= DESCRIPTION =================
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        "Product Detail",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.product.description,
                              textAlign: TextAlign.start,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ================= ADD TO CART =================
                  // CommonButton(
                  //   title: "Add To Basket",
                  //   onTap: () {
                  //     if (controller.isSoldOut) {
                  //       CommonToast.show(
                  //         "Your selected packaging is Out Of Stock",
                  //         type: ToastType.warning,
                  //       );
                  //     } else {
                  //       Get.back();
                  //       CommonLoader.show();
                  //       final cartController = Get.put(CartController());
                  //
                  //       // ✅ Pass the selling price (after discount)
                  //       cartController.addToCart(
                  //         product: widget.product,
                  //         packaging: controller.selectedPackaging,
                  //         unitPrice: controller.sellingPrice,
                  //         quantity: controller.quantity.value,
                  //       );
                  //
                  //       CommonLoader.hide();
                  //     }
                  //   },
                  // ),
                  CommonButton(
                    title: "Add To Basket",
                    onTap: () async {
                      if (controller.isSoldOut) {
                        CommonToast.show(
                          "Your selected packaging is Out Of Stock",
                          type: ToastType.warning,
                        );
                        return;
                      }
                      Get.back();
                      CommonLoader.show();

                      final cartController = Get.find<CartController>();

                      final existingItem = cartController.cartItems
                          .firstWhereOrNull(
                            (e) =>
                                e.product.id == widget.product.id &&
                                e.packagingLabel ==
                                    controller.selectedPackaging.label,
                          );

                      if (existingItem != null) {
                        /// UPDATE quantity
                        await cartController.addToCart(
                          product: widget.product,
                          packaging: controller.selectedPackaging,
                          unitPrice: controller.sellingPrice,
                          quantity: controller.quantity.value,
                          replaceQuantity: true,
                        );
                      } else {
                        /// ADD new item
                        await cartController.addToCart(
                          product: widget.product,
                          packaging: controller.selectedPackaging,
                          unitPrice: controller.sellingPrice,
                          quantity: controller.quantity.value,
                          replaceQuantity: false,
                        );
                      }

                      CommonLoader.hide();
                      Get.back();
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= IMAGE SLIDER =================
  Widget _buildImageSlider() {
    final images = widget.product.images ?? [];
    final hasImages = images.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: SvgPicture.asset("assets/svg/back_arrow_icon.svg"),
              ),
              const SizedBox(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220.h,
            child: hasImages
                ? PageView.builder(
                    controller: controller.pageController,
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        controller.currentIndex.value = index,
                    itemBuilder: (_, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.contain,
                        memCacheHeight: 400, // medium quality
                        memCacheWidth: 400, // medium quality
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          if (hasImages && images.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 5,
                    width: controller.currentIndex.value == index ? 15 : 5,
                    decoration: BoxDecoration(
                      color: controller.currentIndex.value == index
                          ? AppColors.primary
                          : const Color(0xffB3B3B3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, {bool isAdd = false}) {
    return Icon(icon, color: isAdd ? AppColors.primary : Colors.grey.shade600);
  }
}
