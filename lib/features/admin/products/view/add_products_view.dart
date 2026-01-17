import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_drop_down.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
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
                                height: 150.h,
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
                                      width: 150.h,
                                      height: 150.h,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      controller.productImages[index],
                                      width: 150.h,
                                      height: 150.h,
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
                  CommonTextField(
                    label: "Brand",
                    hint: "Enter brand",
                    controller: controller.brandController,
                  ),
                ],
              ),
            ),
            _sectionCard(
              title: "Available Stores",
              child: Obx(
                    () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// STORE SELECTION
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: controller.stores.map((store) {
                        final selected = controller.storeConfigs
                            .any((e) => e.storeId == store.id);

                        return FilterChip(
                          label: Text(store.name),
                          selected: selected,
                          selectedColor:
                          AppColors.primary.withOpacity(0.25),
                          checkmarkColor: AppColors.primary,
                          onSelected: (value) {
                            controller.toggleStore(store, value);
                          },
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 24.h),

                    /// STORE CONFIG
                    Column(
                      children: controller.storeConfigs.map((store) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 20.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// STORE NAME
                              Text(
                                store.storeName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              SizedBox(height: 12.h),

                              /// UNIT
                              CommonDropdownField<String>(
                                label: "Unit",
                                hint: "Select unit",
                                value: store.unit.isEmpty ? null : store.unit,
                                items: const [
                                  DropdownMenuItem(value: "Kg", child: Text("Kg")),
                                  DropdownMenuItem(value: "Gram", child: Text("Gram")),
                                  DropdownMenuItem(value: "Liter", child: Text("Liter")),
                                  DropdownMenuItem(value: "Ml", child: Text("Ml")),
                                  DropdownMenuItem(value: "Packet", child: Text("Packet")),
                                ],
                                onChanged: (v) {
                                  store.unit = v!;
                                  store.packaging.clear();

                                  /// ✅ AUTO ADD PACKET PACKAGING
                                  if (v == "Packet") {
                                    store.packaging.add(
                                      PackagingModel(
                                        label: "Packet",
                                        price: 0,
                                        sku: "",
                                        discount: 0,
                                        quantity: 0,
                                        isDefault: true,
                                      ),
                                    );
                                  }

                                  controller.storeConfigs.refresh();
                                },
                              ),

                              SizedBox(height: 16.h),

                              /// PACKAGING LIST
                              Column(
                                children: store.packaging.map((pkg) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12.h),
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        /// LABEL + DEFAULT
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                pkg.label,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            const Text("Show to user"),
                                            Radio<bool>(
                                              value: true,
                                              groupValue: pkg.isDefault,
                                              activeColor: AppColors.primary,
                                              onChanged: (_) {
                                                for (var p in store.packaging) {
                                                  p.isDefault = false;
                                                }
                                                pkg.isDefault = true;
                                                controller.storeConfigs.refresh();
                                              },
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8.h),

                                        /// PRICE + SKU
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CommonTextField(
                                                controller: TextEditingController(
                                                    text: pkg.price == 0
                                                        ? ""
                                                        : pkg.price.toString()),
                                                label: "Price",
                                                keyboardType: TextInputType.number,
                                                onChanged: (v) {
                                                  pkg.price =
                                                      double.tryParse(v) ?? 0;
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
                                            Expanded(
                                              child: CommonTextField(
                                                controller:
                                                TextEditingController(text: pkg.sku),
                                                label: "SKU",
                                                onChanged: (v) {
                                                  pkg.sku = v;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 16.h),

                                        /// DISCOUNT + QUANTITY
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CommonTextField(
                                                controller: TextEditingController(
                                                    text: pkg.discount == 0
                                                        ? ""
                                                        : pkg.discount.toString()),
                                                label: "Discount (%)",
                                                keyboardType: TextInputType.number,
                                                onChanged: (v) {
                                                  pkg.discount =
                                                      int.tryParse(v) ?? 0;
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 16.w),
                                            Expanded(
                                              child: CommonTextField(
                                                controller: TextEditingController(
                                                    text: pkg.quantity == 0
                                                        ? ""
                                                        : pkg.quantity.toString()),
                                                label: "Quantity",
                                                keyboardType: TextInputType.number,
                                                onChanged: (v) {
                                                  pkg.quantity =
                                                      int.tryParse(v) ?? 0;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        /// ❌ DELETE (NOT FOR PACKET)
                                        if (store.unit != "Packet")
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                store.packaging.remove(pkg);
                                                controller.storeConfigs.refresh();
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),

                              /// ADD PACKAGING (NOT FOR PACKET)
                              if (store.unit != "Packet")
                                Row(
                                  children: [
                                    Expanded(
                                      child: CommonTextField(
                                        controller:
                                        store.tempPackagingController!,
                                        label: "Add Packaging",
                                        hint: store.unit == "Kg"
                                            ? "e.g. 500g, 1kg"
                                            : store.unit == "Gram"
                                            ? "e.g. 250g"
                                            : store.unit == "Liter"
                                            ? "e.g. 500ml, 1l"
                                            : store.unit == "Ml"
                                            ? "e.g. 100ml"
                                            : "",
                                        onSubmitted: (v) {
                                          if(store.tempPackagingController == null){
                                            CommonToast.show("Please Enter Packaging",type: ToastType.warning);
                                          }else{
                                            if (!controller
                                                .isValidPackagingForUnit(
                                              unit: store.unit,
                                              value: v,
                                            )) {
                                              CommonToast.show(
                                                "Invalid packaging for ${store.unit}",
                                                type: ToastType.warning,
                                              );
                                              return;
                                            }
                                            controller.addPackaging(store, v);
                                            store.tempPackagingController?.clear();
                                          }

                                        },
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    SizedBox(
                                      width: 100.w,
                                      child: CommonButton(
                                        title: "+",
                                        onTap: () {
                                          final value = (store
                                              .tempPackagingController
                                              ?.text ??
                                              '')
                                              .trim();

                                          if (value.isEmpty) return;

                                          if (!controller
                                              .isValidPackagingForUnit(
                                            unit: store.unit,
                                            value: value,
                                          )) {
                                            CommonToast.show(
                                              "Invalid packaging for ${store.unit}",
                                              type: ToastType.warning,
                                            );
                                            return;
                                          }

                                          controller.addPackaging(store, value);
                                          store.tempPackagingController?.clear();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),
            /// ================ DESCRIPTION =================
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
          height: 150.h,
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
