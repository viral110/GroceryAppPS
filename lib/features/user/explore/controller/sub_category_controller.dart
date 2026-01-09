import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class SubcategoryController extends GetxController {
  final String categoryId; // Selected category
  SubcategoryController(this.categoryId);

  var products = <ProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProducts();
    });
  }

  void fetchProducts() async {
    try {
      isLoading.value = true;
      CommonLoader.show();

      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstantStrings.productsCollection)
          .where('category_id', isEqualTo: categoryId)
          // .orderBy('created_at', descending: true)
          .get();

      products.value = snapshot.docs
          .map((doc) => ProductModel.fromDoc(doc))
          .toList();
    } catch (e) {
      log("Error fetching products: $e");
    } finally {
      CommonLoader.hide();
      isLoading.value = false;
    }
  }
}
