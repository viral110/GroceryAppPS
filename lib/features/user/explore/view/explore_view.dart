import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';import 'package:online_groceries_app/features/user/explore/controller/explore_controller.dart';
import 'package:online_groceries_app/features/user/explore/view/subcategory_view.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExploreController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "Find Products",showBack: false,),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SEARCH BAR
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search Store",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15,),
                GestureDetector(
                    onTap: (){
                      Get.bottomSheet(
                        FilterBottomSheet(),
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                      );
                    },
                    child: SvgPicture.asset("assets/svg/filtter_icon.svg")),
                SizedBox(width: 15,),
              ],
            ),


            const SizedBox(height: 20),

            Expanded(
              child: Obx(() {
                if (controller.isSearching) {
                  /// 🔍 SEARCH RESULT GRID
                  return GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final item = products[index];
                      return GestureDetector(
                        onTap: (){
                          Get.to(()=>ProductDetailView());
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
                                  child: Image.asset(
                                    item.image,
                                    height: 90,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// TITLE
                              Text(
                                item.name,
                                style:  TextStyle(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),

                              const SizedBox(height: 4),

                              /// SUBTITLE
                              Text(
                                "180g, Price",
                                style:  TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,

                                ),
                              ),

                              const SizedBox(height: 10),

                              /// PRICE + ADD BUTTON
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.price,
                                    style:  TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
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
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                /// 📦 CATEGORY GRID (DEFAULT)
                return  GridView.builder(
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final item = _categories[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(()=>SubcategoryView());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: item.borderColor,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              item.image,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

          ],
        ),
      ),
    );
  }
}

/// MODEL
class CategoryItem {
  final String title;
  final String image;
  final Color color;
  final Color borderColor;

  CategoryItem({
    required this.title,
    required this.image,
    required this.color,
    required this.borderColor,
  });
}

/// DATA
final List<CategoryItem> _categories = [
  CategoryItem(
    title: "Fresh Fruits\n& Vegetable",
    image: "assets/png/category/fruits.png",
    color: const Color(0xffE9F8EE),
    borderColor: const Color(0xff53B175),
  ),
  CategoryItem(
    title: "Cooking Oil\n& Ghee",
    image: "assets/png/category/oil.png",
    color: const Color(0xffFFF4E8),
    borderColor: const Color(0xffF8A44C),
  ),
  CategoryItem(
    title: "Meat & Fish",
    image: "assets/png/category/meat.png",
    color: const Color(0xffFDECEC),
    borderColor: const Color(0xffF28B82),
  ),
  CategoryItem(
    title: "Bakery & Snacks",
    image: "assets/png/category/bakery.png",
    color: const Color(0xffF4EBFF),
    borderColor: const Color(0xffD1B3FF),
  ),
  CategoryItem(
    title: "Dairy & Eggs",
    image: "assets/png/category/dairy.png",
    color: const Color(0xffFFF9E6),
    borderColor: const Color(0xffFDE68A),
  ),

  CategoryItem(
    title: "Beverages",
    image: "assets/png/category/beverage.png",
    color: const Color(0xffECF8FF),
    borderColor: const Color(0xff90CDF4),
  ),
];


class FilterBottomSheet extends StatelessWidget {
  FilterBottomSheet({super.key});

  final controller = Get.put(FilterController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40.h,),
          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: const Icon(Icons.close,size: 25,),
                ),
                const Text(
                  "Filters",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF2F3F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CATEGORIES
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _checkTile("Eggs", controller.eggs),
                        _checkTile("Noodles & Pasta", controller.noodles),
                        _checkTile("Chips & Crisps", controller.chips),
                        _checkTile("Fast Food", controller.fastFood),

                        const SizedBox(height: 20),

                        /// BRAND
                        Text(
                          "Brand",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _checkTile("Individual Collection", controller.individual),
                        _checkTile("Cocola", controller.cocola),
                        _checkTile("Ifad", controller.ifad),
                        _checkTile("Kazi Farmas", controller.kaziFarmas),
                      ],
                    ),
                  ),

                  CommonButton(
                    title: "Apply Filter",
                    onTap: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  /// CHECKBOX TILE (UNCHANGED LOGIC)
  Widget _checkTile(String title, RxBool value) {
    return Obx(() {
      final isChecked = value.value;

      return InkWell(
        onTap: () => value.value = !isChecked,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: isChecked
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isChecked
                        ? AppColors.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isChecked
                    ? const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isChecked
                      ? AppColors.primary
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class FilterController extends GetxController {
  RxBool eggs = true.obs;
  RxBool noodles = false.obs;
  RxBool chips = false.obs;
  RxBool fastFood = false.obs;

  // Brands
  RxBool individual = false.obs;
  RxBool cocola = true.obs;
  RxBool ifad = false.obs;
  RxBool kaziFarmas = false.obs;
}
