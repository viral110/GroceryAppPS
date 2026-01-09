import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/admin/products/controller/product_list_controller.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'add_products_view.dart';

class AdminProductsView extends StatelessWidget {
  AdminProductsView({super.key});

  final controller = Get.put(ProductListController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= HEADER =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Products",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(
              width: 160.w,
              child: CommonButton(
                title: "Add Product",
                onTap: () {
                  Get.to(() => AdminAddProductView())?.then(
                        (_) => controller.fetchProducts(),
                  );
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        /// ================= TABLE HEADER =================
        _tableHeader(),

        SizedBox(height: 12.h),

        /// ================= PRODUCT LIST =================
        Obx(() {
          if (controller.isLoading.value) {
            return  Padding(
              padding:  EdgeInsets.only(top: 200.h),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary,)),
            );
          }

          if (controller.products.isEmpty) {
            return  Padding(
              padding: EdgeInsets.only(top: 200.h),
              child: Center(child: Text("No products found")),
            );
          }

          return Column(
            children: controller.products
                .map((product) => _productRow(product))
                .toList(),
          );
        }),
      ],
    );
  }

  // ---------------- TABLE HEADER ----------------
  Widget _tableHeader() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children:  [
          Expanded(child: Text("Product Name", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.sp))),
          Expanded(child: Text("Category", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.sp))),
          Expanded(child: Text("Price", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.sp))),
          Expanded(child: Text("Discount", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.sp))),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  // ---------------- PRODUCT ROW ----------------
  Widget _productRow(ProductModel product) {


    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(child: Text(product.name,style: TextStyle(fontSize: 17.sp),)),
          Expanded(child: Text(product.categoryName,style: TextStyle(fontSize: 17.sp))),
          Expanded(child: Text("₹${product.price}",style: TextStyle(fontSize: 17.sp))),
          Expanded(
            child: Text(
              "${product.discount}%",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17.sp
              ),
            ),
          ),

          /// ================= ACTION MENU =================
          PopupMenuButton<String>(
            icon:  Icon(Icons.more_vert, size: 30.h),
            color: Colors.white,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "update",
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text("Update"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Delete", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == "update") {
                /// 👉 OPEN EDIT SCREEN
                Get.to(
                      () => AdminAddProductView(),
                  arguments: product,
                )?.then((_) => controller.fetchProducts());
              } else if (value == "delete") {
                _confirmDelete(product);
              }
            },
          ),
        ],
      ),
    );
  }

  // ---------------- DELETE CONFIRMATION ----------------
  void _confirmDelete(ProductModel product) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete ${product.name}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(product);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }
}
