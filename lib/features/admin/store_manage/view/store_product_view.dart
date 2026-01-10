import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/admin/store_manage/controller/store_products_controller.dart';
import 'package:online_groceries_app/features/admin/store_manage/models/store_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class StoreProductView extends StatelessWidget {
  final StoreModel store;
  const StoreProductView({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreProductController>(
        init: StoreProductController(store.id),
        builder: (controller) {
        return Scaffold(
          appBar: CommonAppBar(
            title: "${store.name} Products",
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.products.isEmpty) {
              return const Center(child: Text("No products found"));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = controller.products[index];
                final stock = controller.getStock(product, store.id);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.thumbnail,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 30),
                        ),
                      ),
                      const SizedBox(width: 12),

                      /// Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹${product.price}",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),

                            /// ✅ STOCK
                            Text(
                              "Stock: $stock",
                              style: TextStyle(
                                color: stock <= 5 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Edit Stock Button
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _updateStockDialog(
                          context,
                          product,
                          store.id,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );

          }),
        );
      }
    );
  }
  void _updateStockDialog(
      BuildContext context,
      ProductModel product,
      String storeId,
      ) {
    final controller = Get.find<StoreProductController>();

    final storeStock = product.storeStocks.firstWhere(
          (e) => e.storeId == storeId,
    );

    final stockController =
    TextEditingController(text: storeStock.stock.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        title: const Text("Update Stock"),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Stock Quantity",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:  Text("Cancel",style: TextStyle(fontSize: 18.sp,color: Colors.black),),
          ),

          SizedBox(
            width: 150.w,
            child: CommonButton(title: "Update", onTap: () async{
              final newStock = int.tryParse(stockController.text) ?? 0;

              await controller.updateStoreStock(
                productId: product.id,
                storeId: storeId,
                newStock: newStock,
              );

              Get.back();
            },),
          )

        ],
      ),
    );
  }

}
