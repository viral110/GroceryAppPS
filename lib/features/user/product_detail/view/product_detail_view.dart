import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: SafeArea(
              child: Obx(() => _buildImageSlider()),
            ),
          ),

          /// ================= DETAILS =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  /// TITLE + FAV
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Obx(() {
                        final isFav = favouriteController
                            .isFavourite(widget.product.id);
                        return GestureDetector(
                          onTap: () =>
                              favouriteController.toggleFavourite(widget.product),
                          child: Icon(
                            isFav
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// SELECTED PACKAGING
                  Obx(() => Text(
                    "${controller.selectedPackaging.label}, Price",
                    style: const TextStyle(color: Colors.grey),
                  )),

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
                            label:
                            Text(controller.sortedPackaging[index]),
                            selected: isSelected,
                            selectedColor:
                            AppColors.primary.withOpacity(0.15),
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
                            onSelected: (_) =>
                                controller.selectWeight(index),
                          );
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  /// ================= QTY + PRICE =================
                  Obx(
                        () => Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
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
                                border: Border.all(
                                    color: Colors.grey.shade300),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  controller.quantity.value.toString(),
                                  style:
                                  const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: controller.incrementQuantity,
                              child:
                              _qtyButton(Icons.add, isAdd: true),
                            ),
                          ],
                        ),
                        Text(
                          "₹${controller.totalPrice.value.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 32),

                  /// ================= DESCRIPTION =================
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent, // 👈 remove divider
                  ),
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
                            maxLines: 2,
                            overflow:TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                  /// ================= ADD TO CART =================
                  CommonButton(
                    title:  "Add To Basket",
                    onTap:  () {
                      if(controller.isSoldOut){
                        CommonToast.show("Your selected packaging Out Of stock",type: ToastType.warning);
                      }else{
                        Get.back();
                        Get.back();
                        CommonLoader.show();
                        final cartController =
                        Get.find<CartController>();
                        cartController.addToCart(
                          product: widget.product,
                          packaging: controller.selectedPackaging,
                          unitPrice: controller.unitPrice,
                          quantity: controller.quantity.value,
                        );
                        Get.find<BottomNavController>().changeTab(2);
                        CommonLoader.hide();
                      }

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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: SvgPicture.asset(
                "assets/svg/back_arrow_icon.svg",
              ),
            ),
            const SizedBox(),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 220.h,
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: widget.product.images.length,
            onPageChanged: (index) =>
            controller.currentIndex.value = index,
            itemBuilder: (_, index) {
              return Image.network(
                widget.product.images[index],
                fit: BoxFit.contain,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.product.images.length,
                (index) => AnimatedContainer(
              duration:
              const Duration(milliseconds: 300),
              margin:
              const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              width: controller.currentIndex.value == index
                  ? 15
                  : 5,
              decoration: BoxDecoration(
                color: controller.currentIndex.value == index
                    ? AppColors.primary
                    : const Color(0xffB3B3B3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, {bool isAdd = false}) {
    return Icon(
      icon,
      color: isAdd ? Colors.green : Colors.grey.shade600,
    );
  }
}
