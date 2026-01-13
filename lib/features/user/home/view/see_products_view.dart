import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/home/controller/see_product_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class SeeAllProductsView extends StatelessWidget {
  final SeeAllType type;
  final String title;

  const SeeAllProductsView({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SeeAllProductsController(type),
      tag: type.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.products.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          return GridView.builder(
            itemCount: controller.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, index) {
              final item = controller.products[index];
              final discountedPrice =
                  item.price - (item.price * item.discount / 100);

              return _productCard(item, discountedPrice);
            },
          );
        }),
      ),
    );
  }

  Widget _productCard(ProductModel item, double discountedPrice) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Image.network(item.thumbnail, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
          ),
          Text(item.priceUnit, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₹${discountedPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.discount > 0)
                    Text(
                      "₹${item.price}",
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
