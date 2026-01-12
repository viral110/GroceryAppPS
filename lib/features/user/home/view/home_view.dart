import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/home/controller/home_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

import '../../product_detail/view/product_detail_view.dart';

class GroceryHomeScreen extends StatelessWidget {
  const GroceryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset("assets/svg/logo_2.svg", height: 27.h),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color(0xff4C4F4D),
                  ),
                  const SizedBox(width: 4),

                  Obx(() {
                    if (controller.stores.isEmpty) {
                      return const Text(
                        "Loading...",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      );
                    }

                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedStoreId.value.isEmpty
                            ? null
                            : controller.selectedStoreId.value,
                        icon: const SizedBox(),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        items: controller.stores.map((store) {
                          return DropdownMenuItem<String>(
                            value: store.id,
                            child: Text(
                              store.address, // 👈 shows Firestore address
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),

                        onChanged: (value) async {
                          if (value == null) return;
                          await controller.onStoreChanged(value);
                          // controller.selectedStoreId.value = value!;
                          // final user = UserService.getUserFromHive();
                          // user.storeId = controller.selectedStoreId.value;
                          // UserService().updateUser(user);
                        },
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 12),

              /// 🔍 Search
              TextField(
                readOnly: true,
                onTap: () {
                  Get.find<BottomNavController>().changeTab(1);
                },
                decoration: InputDecoration(
                  hintText: "Search Store",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🥕 Banner
              Obx(() {
                if (controller.isBannerLoading.value) {
                  return const SizedBox(height: 160);
                }

                if (controller.banners.isEmpty) {
                  return const SizedBox.shrink(); // 👈 no data → nothing shown
                }
                return Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: controller.banners.length,
                      itemBuilder: (context, index, realIndex) {
                        final banner = controller.banners[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            banner.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 160,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(seconds: 1),
                        viewportFraction: 0.92,
                        enlargeCenterPage: true,
                        onPageChanged: (index, _) {
                          controller.currentIndex.value = index;
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.banners.length,
                        (index) => Obx(() {
                          final isActive =
                              controller.currentIndex.value == index;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : Colors.grey.shade400.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              /// ⭐ Exclusive Offers
              Obx(() {
                if (controller.exclusiveOffers.isEmpty) {
                  return const Text("NO Exclusive PRODUCT FOUND");
                }

                return Column(
                  children: [
                    _sectionHeader("Exclusive Offer"),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 248.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.exclusiveOffers.length,
                        itemBuilder: (_, index) {
                          final product = controller.exclusiveOffers[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: ProductCard(product: product),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.bestSelling.isEmpty) {
                  return Text("NO BEST SELLING PRODUCT FOUND");
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Best Selling"),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 248.h,
                      child: ListView.builder(
                        itemCount: controller.bestSelling.length,
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final product = controller.bestSelling[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: ProductCard(product: product),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),

              /// 🛒 Groceries
              _sectionHeader("Groceries"),
              const SizedBox(height: 12),

              SizedBox(
                height: 105.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: controller.groceriesCategory.length,
                  itemBuilder: (context, index) {
                    return _categoryTile(
                      title: controller.groceriesCategory[index]['title'],
                      image: controller.groceriesCategory[index]['image'],
                      color: controller.groceriesCategory[index]['color'],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              Obx(() {
                if (controller.randomProducts.isEmpty) {
                  return Text("NO PRODUCT FOUND");
                }

                return SizedBox(
                  height: 248.h,
                  child: ListView.builder(
                    itemCount: controller.randomProducts.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final product = controller.randomProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(right: 20.w),
                        child: ProductCard(product: product),
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        Text(
          "See all",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// CATEGORY TILE
  Widget _categoryTile({
    required String title,
    required String image,
    required Color color,
  }) {
    return Container(
      width: 248.w,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(right: 14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Image.asset(image, height: 71.h, width: 71.h),
          SizedBox(width: 15.w),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.sp),
          ),
        ],
      ),
    );
  }
}

/// 🧺 PRODUCT CARD
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountedPrice =
        product.price - (product.price * product.discount / 100);
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailView(product: product));
      },
      child: Container(
        width: 174.w,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// 🖼 PRODUCT IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),
            Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp),
            ),
            const SizedBox(height: 4),
            Text(
              product.priceUnit,
              style: const TextStyle(color: Color(0xff7C7C7C)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Discounted Price
                    Text(
                      "₹${discountedPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                    ),

                    // Original Price (only if discount exists)
                    if (product.discount > 0)
                      Text(
                        "₹${product.price.toStringAsFixed(2)}",
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
                    final homeController = Get.find<HomeController>();
                    await homeController.addProductToCart(product);

                    Get.find<BottomNavController>().changeTab(2);
                  },
                  child: Container(
                    height: 45.h,
                    width: 45.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
