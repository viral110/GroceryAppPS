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
          backgroundColor: const Color(0xffF5F6FA),
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
              padding: EdgeInsets.all(16.w),
              itemCount: controller.products.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final product = controller.products[index];
                final storeConfig =
                controller.getStoreConfig(product);

                if (storeConfig == null) return const SizedBox();

                return Container(
                  padding: EdgeInsets.all(14.w),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// PRODUCT HEADER
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.thumbnail,
                              width: 70.h,
                              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                              height: 70.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 30),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      /// PACKAGING LIST
                      Column(
                        children: storeConfig.packaging.map((pkg) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                /// PACKAGING INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pkg.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "₹${pkg.price}  |  ${pkg.discount}% off",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// QUANTITY
                                Text(
                                  pkg.quantity == 0
                                      ? "Out of Stock"
                                      : "Qty: ${pkg.quantity}",
                                  style: TextStyle(
                                    color: pkg.quantity == 0
                                        ? Colors.red
                                        : pkg.quantity <= 5
                                        ? Colors.orange
                                        : Colors.green,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: AppColors.primary),
                                  onPressed: () =>
                                      _updateQtyDialog(
                                        context,
                                        controller,
                                        product,
                                        pkg,
                                      ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    pkg.isDefault ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: pkg.isDefault ? AppColors.primary : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    await controller.setDefaultPackaging(
                                      productId: product.id,
                                      storeId: controller.storeId,
                                      selectedLabel: pkg.label,
                                    );
                                  },
                                ),

                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  void _updateQtyDialog(
      BuildContext context,
      StoreProductController controller,
      ProductModel product,
      PackagingModel pkg,
      ) {
    final qtyController =
    TextEditingController(text: pkg.quantity.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Quantity"),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Quantity"),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          SizedBox(
            width: 140.w,
            child: CommonButton(
              title: "Update",
              onTap: () async {
                final newQty =
                    int.tryParse(qtyController.text) ?? 0;

                await controller.updatePackagingQuantity(
                  productId: product.id,
                  storeId: controller.storeId,
                  packagingLabel: pkg.label,
                  newQty: newQty,
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}
