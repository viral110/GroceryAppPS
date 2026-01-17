import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/home/controller/home_controller.dart';
import 'package:online_groceries_app/features/user/home/controller/see_product_controller.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';
import 'package:online_groceries_app/services/user_services.dart';
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

              // final discountedPrice =
              //     item.price - (item.price * item.discount / 100);

              return _productCard(item,);
            },
          );
        }),
      ),
    );
  }

  Widget _productCard(ProductModel item) {
    final storeConfig = item.storeConfigs
        .firstWhereOrNull((s) => s.storeId == UserService.getUserFromHive().storeId);

    final PackagingModel? userPackaging = storeConfig?.packaging
        .firstWhereOrNull((p) => p.isDefault);


    final double mrp = userPackaging?.price ?? 0.0;
    final int discount = userPackaging?.discount ?? 0;

    /// ✅ DISCOUNTED PRICE (MINUS)
    final double sellingPrice = discount > 0
        ? mrp - (mrp * discount / 100)
        : mrp;
    /// 🔴 STOCK CHECK
    final int quantity = userPackaging?.quantity ?? 0;
    final bool isSoldOut = quantity <= 0;
    return GestureDetector(
      onTap: (){
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
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.thumbnail,
                      fit: BoxFit.contain,
                      height: 100.h,
                      width: 100.h,
                    ),
                  ),
                ),

                if (isSoldOut)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
            const SizedBox(height: 8),
            Text(
              item.name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
            ),
            Text(storeConfig?.unit??"-", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${sellingPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isSoldOut ? Colors.grey : Colors.black,
                      ),
                    ),
                    if (userPackaging!.discount > 0)
                      Text(
                        "₹${mrp}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: isSoldOut
                      ? (){
                    Get.to(() => ProductDetailView(product: item));
                  }
                      :()async{
                    Get.back();
                    CommonLoader.show();
                    final homeController = Get.find<HomeController>();
                    await homeController.addProductToCart(item,UserService.getUserFromHive().storeId);
                    Get.find<BottomNavController>().changeTab(2);
                    CommonLoader.hide();
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
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
