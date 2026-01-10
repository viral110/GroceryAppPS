import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/home/controller/home_controller.dart';
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

                        onChanged: (value) {
                          controller.selectedStoreId.value = value!;
                          final user =UserService.getUserFromHive();
                          user.storeId = controller.selectedStoreId.value;
                          UserService().updateUser(user);
                          },
                      ),
                    );
                  }),
                ],
              ),

              SizedBox(height: 12),

              /// 🔍 Search
              TextField(
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
                // return SizedBox(
                //   height: 130.h,
                //   child: PageView.builder(
                //     itemCount: controller.banners.length,
                //     onPageChanged: controller.onPageChanged,
                //     itemBuilder: (context, index) {
                //       final banner = controller.banners[index];
                //       return Container(
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(16),
                //           image: DecorationImage(
                //             image: NetworkImage(banner.image),
                //             fit: BoxFit.cover,
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // );
              }),

              const SizedBox(height: 20),

              /// ⭐ Exclusive Offer
              _sectionHeader("Exclusive Offer"),
              const SizedBox(height: 12),
              SizedBox(
                height: 248.h,
                child: ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 20.w),
                      child: ProductCard(
                        title: "Organic Bananas",
                        weight: "7pcs, Priceg",
                        price: "₹ 4.99",
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 Best Selling
              _sectionHeader("Best Selling"),
              const SizedBox(height: 12),
              SizedBox(
                height: 248.h,
                child: ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 20.w),
                      child: ProductCard(
                        title: "Organic Bananas",
                        weight: "7pcs, Priceg",
                        price: "₹ 4.99",
                      ),
                    );
                  },
                ),
              ),

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

              SizedBox(
                height: 248.h,
                child: ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 20.w),
                      child: ProductCard(
                        title: "Organic Bananas",
                        weight: "7pcs, Priceg",
                        price: "₹ 4.99",
                      ),
                    );
                  },
                ),
              ),
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
  final String title;
  final String weight;
  final String price;

  const ProductCard({
    super.key,
    required this.title,
    required this.weight,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailView());
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
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp),
            ),
            const SizedBox(height: 4),
            Text(weight, style: const TextStyle(color: Color(0xff7C7C7C))),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                ),
                Container(
                  height: 45.h,
                  width: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
