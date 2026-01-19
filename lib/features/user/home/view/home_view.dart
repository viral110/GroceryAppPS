import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/home/controller/home_controller.dart';
import 'package:online_groceries_app/features/user/home/controller/see_product_controller.dart';
import 'package:online_groceries_app/features/user/home/view/see_products_view.dart';
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
                  hintText: "Search products/category",
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
                            // ✅ Add error handling for banner images
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              );
                            },
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

              /// ⭐ Exclusive Offers
              Obx(() {
                if (controller.exclusiveOffers.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      const SizedBox.shrink(),
                    ],
                  );
                }

                return Column(
                  children: [
                    _sectionHeader(
                      "Exclusive Offer",
                      onSeeAll: () {
                        Get.to(
                          () => const SeeAllProductsView(
                            type: SeeAllType.exclusive,
                            title: "Exclusive Offers",
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260.h,
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

              Obx(() {
                if (controller.bestSelling.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      const SizedBox.shrink(),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      "Best Selling",
                      onSeeAll: () {
                        Get.to(
                          () => const SeeAllProductsView(
                            type: SeeAllType.bestSelling,
                            title: "Best Selling",
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260.h,
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
              _sectionHeader(
                "Groceries",
                onSeeAll: () {
                  Get.to(
                    () => const SeeAllProductsView(
                      type: SeeAllType.random,
                      title: "Groceries",
                    ),
                  );
                },
              ),
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
                  height: 260.h,
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
  Widget _sectionHeader(String title, {required VoidCallback onSeeAll}) {
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
        TextButton(
          onPressed: () {
            onSeeAll();
          },
          child: Text(
            "See all",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
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
    final storeConfig = product.storeConfigs.firstWhereOrNull(
      (s) => s.storeId == UserService.getUserFromHive().storeId,
    );

    final PackagingModel? userPackaging = storeConfig?.packaging
        .firstWhereOrNull((p) => p.isDefault);

    final double mrp = userPackaging?.price ?? 0.0;
    final int discount = userPackaging?.discount ?? 0;

    final double sellingPrice = discount > 0
        ? mrp - (mrp * discount / 100)
        : mrp;

    /// 🔴 STOCK CHECK
    final int quantity = userPackaging?.quantity ?? 0;
    final bool isSoldOut = quantity <= 0;

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
          children: [
            /// 🖼 IMAGE + SOLD OUT TAG
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.thumbnail,
                      fit: BoxFit.contain,
                      height: 100.h,
                      width: 100.h, // ✅ Add error handling for product images
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 100.h,
                          width: 100.h,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
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

            SizedBox(height: 10.h),

            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp),
            ),

            const SizedBox(height: 4),

            Text(
              userPackaging?.label ?? "-",
              style: const TextStyle(color: Color(0xff7C7C7C)),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// PRICE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${sellingPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: isSoldOut ? Colors.grey : Colors.black,
                      ),
                    ),

                    if (discount > 0)
                      Text(
                        "₹${mrp.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),

                /// ➕ ADD BUTTON
                GestureDetector(
                  onTap: isSoldOut
                      ? () {
                          Get.to(() => ProductDetailView(product: product));
                        }
                      : () async {
                          CommonLoader.show();
                          final homeController = Get.find<HomeController>();
                          await homeController.addProductToCart(
                            product,
                            UserService.getUserFromHive().storeId,
                          );
                          Get.find<BottomNavController>().changeTab(2);
                          CommonLoader.hide();
                        },
                  child: Container(
                    height: 45.h,
                    width: 45.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 20),
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
