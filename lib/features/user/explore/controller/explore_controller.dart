import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/models/product_item_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class ExploreController extends GetxController {
  final searchController = TextEditingController();
  final searchText = "".obs;

  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  RxList<ProductModel> searchedProducts = <ProductModel>[].obs;

  final _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCategories();
      fetchAllProducts(); // load all products initially
    });
    // Search listener
    searchController.addListener(() {
      onSearchChanged(searchController.text);
    });
  }

  void onSearchChanged(String value) {
    searchText.value = value.trim();

    if (searchText.value.isEmpty) {
      searchedProducts.clear();
    } else {
      // Filter locally by product name
      searchedProducts.value = allProducts
          .where(
            (p) =>
                p.name.toLowerCase().contains(searchText.value.toLowerCase()),
          )
          .toList();
    }
  }

  bool get isSearching => searchText.value.isNotEmpty;

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      CommonLoader.show();
      final snapshot = await _firestore
          .collection(AppConstantStrings.categoryCollection)
          .orderBy('created_at', descending: false)
          .get();

      categories.value = snapshot.docs
          .map((doc) => CategoryModel.fromSnapshot(doc.id, doc.data()))
          .toList();
    } catch (e) {
      log("Error fetching categories: ${e.toString()}");
    } finally {
      CommonLoader.hide();
      isLoading.value = false;
    }
  }

  Future<void> fetchAllProducts() async {
    try {
      isLoading.value = true;
      CommonLoader.show();

      final snapshot = await _firestore
          .collection(AppConstantStrings.productsCollection)
          .get();

      allProducts.value = snapshot.docs
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
