import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_drop_down.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/admin/products/controller/add_products_controller.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminAddProductView extends StatelessWidget {
  AdminAddProductView({super.key});

  final AdminProductController controller = Get.put(AdminProductController());

  @override
  Widget build(BuildContext context) {
    /// ✅ EDIT MODE SUPPORT
    final ProductModel? product = Get.arguments;
    if (product != null && !controller.isEdit.value) {
      controller.setEditProduct(product);
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CommonAppBar(
        title: controller.isEdit.value ? "Update Product" : "Add Product",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            /// ================= THUMBNAIL =================
            _sectionCard(
              title: "Thumbnail Image",
              child: Obx(() {
                final hasImage =
                    controller.thumbnailBytes.value != null ||
                    controller.thumbnailFile.value != null ||
                    controller.thumbnailUrl.value.isNotEmpty;

                return GestureDetector(
                  onTap: controller.pickThumbnail,
                  child: Stack(
                    children: [
                      hasImage ? _thumbnailWidget() : _addBox(),

                      /// REMOVE
                      if (hasImage)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: controller.removeThumbnail,
                            child: _removeIcon(),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),

            SizedBox(height: 24.h),

            /// ================= PRODUCT IMAGES =================
            _sectionCard(
              title: "Product Images (Max 3)",
              child: Obx(() {
                final oldImages = controller.productImageUrls;
                final newImages = kIsWeb
                    ? controller.productImagesBytes
                    : controller.productImages;

                final totalCount = oldImages.length + newImages.length;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (totalCount < 3)
                      GestureDetector(
                        onTap: controller.pickProductImages,
                        child: _addBox(),
                      ),

                    /// OLD NETWORK IMAGES
                    ...List.generate(oldImages.length, (index) {
                      final imageUrl = oldImages[index];

                      return Stack(
                        key: ValueKey(imageUrl), // 🔥 VERY IMPORTANT
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.r),
                            child: Image.network(
                              imageUrl,
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.prefer,
                              width: 150.h,
                              height: 150.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height:  150.h,
                                width: 150.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.image, size: 30),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                controller.removeProductImage(
                                  isOld: true,
                                  index: index,
                                );
                              },
                              child: _removeIcon(),
                            ),
                          ),
                        ],
                      );
                    }),

                    /// NEW LOCAL IMAGES
                    /// NEW LOCAL IMAGES
                    ...List.generate(newImages.length, (index) {
                      return Stack(
                        key: ValueKey(
                          kIsWeb
                              ? controller.productImagesBytes[index].hashCode
                              : controller.productImages[index].path,
                        ), // 🔥 VERY IMPORTANT

                        children: [
                          GestureDetector(
                            onTap: () => controller.replaceProductImage(index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.r),
                              child: kIsWeb
                                  ? Image.memory(
                                      controller.productImagesBytes[index],
                                      width:  150.h,
                                      height:  150.h,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      controller.productImages[index],
                                      width: 150.h,
                                      height:  150.h,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                controller.removeProductImage(
                                  isOld: false,
                                  index: index,
                                );
                              },
                              child: _removeIcon(),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                );
              }),
            ),

            SizedBox(height: 24.h),

            /// ================= BASIC DETAILS =================
            _sectionCard(
              title: "Basic Details",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          label: "Product Name",
                          hint: "Enter product name",
                          controller: controller.nameController,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Obx(() {
                          if (controller.isCategoryLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return CommonDropdownField<String>(
                            label: "Category",
                            hint: "Select category",
                            value: controller.selectedCategoryId.value.isEmpty
                                ? null
                                : controller.selectedCategoryId.value,
                            items: controller.categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.id,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6.r),
                                      child: Image.network(
                                        cat.imageUrl,
                                        width: 30.h,
                                        height: 30.h,
                                        webHtmlElementStrategy:
                                            WebHtmlElementStrategy.prefer,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image, size: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(cat.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              final cat = controller.categories.firstWhere(
                                (e) => e.id == value,
                              );
                              controller.selectedCategoryId.value = cat.id;
                              controller.selectedCategory.value = cat.name;
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          label: "Brand",
                          hint: "Enter brand",
                          controller: controller.brandController,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Obx(
                          () => CommonDropdownField<String>(
                            label: "Price Unit",
                            hint: "Select unit",
                            value: controller.selectedUnit.value.isEmpty
                                ? null
                                : controller.selectedUnit.value,
                            items: const [
                              DropdownMenuItem(value: "Kg", child: Text("Kg")),
                              DropdownMenuItem(
                                value: "Gram",
                                child: Text("Gram"),
                              ),
                              DropdownMenuItem(
                                value: "Liter",
                                child: Text("Liter"),
                              ),
                              DropdownMenuItem(value: "Ml", child: Text("Ml")),
                              DropdownMenuItem(
                                value: "Piece",
                                child: Text("Piece"),
                              ),
                              DropdownMenuItem(
                                value: "Packet",
                                child: Text("Packet"),
                              ),
                              DropdownMenuItem(
                                value: "Box",
                                child: Text("Box"),
                              ),
                            ],
                            onChanged: (v) =>
                                controller.selectedUnit.value = v!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            _sectionCard(
              title: "Price & Stock",
              child: Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      label: "Price",
                      hint: "Enter price",
                      keyboardType: TextInputType.number,
                      controller: controller.priceController,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CommonTextField(
                      label: "Stock",
                      hint: "Enter stock",
                      keyboardType: TextInputType.number,
                      controller: controller.stockController,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// ================= PACKAGING =================
            _sectionCard(
              title: "Packaging Options",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Wrap(
                      spacing: 13.w,
                      children: controller.packagingList
                          .map(
                            (e) => Chip(
                              backgroundColor: AppColors.primary.withOpacity(0.3),
                              label: Text(e,style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800
                              ),),
                              onDeleted: () =>
                                  controller.packagingList.remove(e),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          label: "Add Packaging",
                          hint: "e.g. 250g, 1kg",
                          controller: controller.packagingController,
                        ),
                      ),
                      SizedBox(width: 30.w,),
                      SizedBox(
                        width: 100.w,
                        child: CommonButton(title: "+", onTap: () {
                          controller.addPackaging();
                        },fontSize: 30.sp,),
                      )
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// ================= DESCRIPTION =================
            _sectionCard(
              title: "Product Description",
              child: CommonTextField(
                label: "Description",
                hint: "Enter product description",
                maxLines: 4,
                controller: controller.descriptionController,
              ),
            ),

            SizedBox(height: 32.h),

            Obx(
              () => CommonButton(
                title: controller.isLoading.value
                    ? "Saving..."
                    : controller.isEdit.value
                    ? "Update Product"
                    : "Save Product",
                onTap: controller.isLoading.value
                    ? () {}
                    : controller.saveProduct,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailWidget() {
    if (controller.thumbnailBytes.value != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Image.memory(
          controller.thumbnailBytes.value!,
          width: 150.h,
          height:150.h,
          fit: BoxFit.cover,
        ),
      );
    } else if (controller.thumbnailFile.value != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Image.file(
          controller.thumbnailFile.value!,
          width: 150.h,
          height: 150.h,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Image.network(
          controller.thumbnailUrl.value,
          width: 150.h,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          height: 150.h,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget _addBox() => Container(
    height: 150.h,
    width: 150.h,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.add, size: 30),
  );

  Widget _removeIcon() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.6),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.close, color: Colors.white, size: 14),
  );

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 18, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}
