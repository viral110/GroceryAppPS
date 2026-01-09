import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/admin/settings/controller/manage_category_controller.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminManageCategoryView extends StatelessWidget {
  AdminManageCategoryView({super.key});

  final CategoryController controller = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: const CommonAppBar(title: "Manage Categories"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ADD CATEGORY
              _sectionCard(
                title: "Add Category",
                child: Column(
                  children: [
                    /// IMAGE
                    GestureDetector(
                      onTap: controller.pickImage,
                      child: Obx(
                        () => ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey.shade200,
                            child: controller.imageBytes.value != null
                                ? Image.memory(
                                    controller.imageBytes.value!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.add, size: 36),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// NAME
                    CommonTextField(
                      label: "Category Name",
                      hint: "Enter category name",
                      controller: controller.nameController,
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: 180.w,
                      child: Obx(
                        () => CommonButton(
                          title: controller.isLoading.value
                              ? "Please wait..."
                              : "Add Category",
                          onTap: controller.addCategory,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              /// LIST TITLE
              Text(
                "Category List",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),

              SizedBox(height: 16.h),

              /// CATEGORY LIST
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No categories found"));
                  }

                  final categories = snapshot.data!.docs
                      .map(
                        (doc) => CategoryModel.fromSnapshot(
                          doc.id,
                          doc.data() as Map<String, dynamic>,
                        ),
                      )
                      .toList();

                  return Column(
                    children: categories.map((category) {
                      return _categoryRow(context, category);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CATEGORY ROW
  Widget _categoryRow(BuildContext context, CategoryModel category) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey.shade200,
            ),
            child: Image.network(
              category.imageUrl ?? '',
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, error, ___) {
                print(error);
                return const Icon(Icons.broken_image);
              },
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Text(
              category.name ?? '',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openEditDialog(context, category),
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () =>
                controller.deleteCategory(category.id, category.imageUrl),
          ),
        ],
      ),
    );
  }

  /// EDIT DIALOG
  void _openEditDialog(BuildContext context, CategoryModel category) {
    controller.openEditCategory(category);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SizedBox(
          width: 400.w,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Category",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// IMAGE
                  GestureDetector(
                    onTap: controller.pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey.shade200,
                        child: controller.imageBytes.value != null
                            ? Image.memory(
                                controller.imageBytes.value!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                webHtmlElementStrategy:
                                    WebHtmlElementStrategy.prefer,
                                controller.oldImageUrl.value,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  CommonTextField(
                    label: "Category Name",
                    hint: "Enter category name",
                    controller: controller.nameController,
                  ),

                  SizedBox(height: 24.h),

                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          title: "Cancel",
                          onTap: () {
                            Get.back();
                            controller.resetForm();
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CommonButton(
                          title: controller.isLoading.value
                              ? "Updating..."
                              : "Update",
                          onTap: () async {
                            await controller.updateCategory();
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// CARD UI
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: [
        BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(0.05)),
      ],
    );
  }
}
