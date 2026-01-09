import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/explore/controller/sub_category_controller.dart';
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
              return Container(
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
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),

                    const SizedBox(height: 10),

                    /// PRICE + ADD BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${AppConstantStrings.rupeeSymbol} ${item.price} ",
                          style: TextStyle(
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
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// MODEL
class BeverageItem {
  final String title;
  final String subtitle;
  final String price;
  final String image;

  BeverageItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.image,
  });
}

/// DATA
final List<BeverageItem> _beverages = [
  BeverageItem(
    title: "Diet Coke",
    subtitle: "355ml, Price",
    price: "\$1.99",
    image: "assets/png/category/beverage.png",
  ),
  BeverageItem(
    title: "Sprite Can",
    subtitle: "325ml, Price",
    price: "\$1.50",
    image: "assets/png/category/beverage.png",
  ),
  BeverageItem(
    title: "Apple & Grape Juice",
    subtitle: "2L, Price",
    price: "\$15.99",
    image: "assets/png/category/beverage.png",
  ),
  BeverageItem(
    title: "Orange Juice",
    subtitle: "2L, Price",
    price: "\$15.99",
    image: "assets/png/category/beverage.png",
  ),
  BeverageItem(
    title: "Coca Cola Can",
    subtitle: "325ml, Price",
    price: "\$4.99",
    image: "assets/png/category/beverage.png",
  ),
  BeverageItem(
    title: "Pepsi Can",
    subtitle: "330ml, Price",
    price: "\$4.99",
    image: "assets/png/category/beverage.png",
  ),
];
