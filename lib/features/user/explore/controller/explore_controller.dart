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

  RxSet<String> selectedCategoryIds = <String>{}.obs;
  RxSet<String> selectedBrands = <String>{}.obs;
  RxList<String> availableBrands = <String>[].obs;

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

  bool get isSearching =>
      searchText.value.isNotEmpty ||
      selectedCategoryIds.isNotEmpty ||
      selectedBrands.isNotEmpty;

  void onSearchChanged(String value) {
    searchText.value = value.trim();
    applyFilters();
    // if (searchText.value.isEmpty) {
    //   searchedProducts.clear();
    // } else {
    //   // Filter locally by product name
    //   searchedProducts.value = allProducts
    //       .where(
    //         (p) =>
    //             p.name.toLowerCase().contains(searchText.value.toLowerCase()),
    //       )
    //       .toList();
    // }
  }

  void applyFilters() {
    List<ProductModel> filtered = allProducts;

    if (searchText.value.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(searchText.value.toLowerCase()),
          )
          .toList();
    }

    if (selectedCategoryIds.isNotEmpty) {
      filtered = filtered
          .where((p) => selectedCategoryIds.contains(p.categoryId))
          .toList();
    }

    if (selectedBrands.isNotEmpty) {
      filtered = filtered
          .where((p) => selectedBrands.contains(p.brand))
          .toList();
    }

    searchedProducts.assignAll(filtered);
  }

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
      _extractBrands();
    } catch (e) {
      log("Error fetching products: $e");
    } finally {
      CommonLoader.hide();
      isLoading.value = false;
    }
  }

  void _extractBrands() {
    availableBrands.assignAll(
      allProducts
          .map((p) => p.brand)
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList(),
    );
  }

  void toggleCategory(String categoryId) {
    selectedCategoryIds.contains(categoryId)
        ? selectedCategoryIds.remove(categoryId)
        : selectedCategoryIds.add(categoryId);

    applyFilters();
  }

  void toggleBrand(String brand) {
    selectedBrands.contains(brand)
        ? selectedBrands.remove(brand)
        : selectedBrands.add(brand);

    applyFilters();
  }

  void clearFilters() {
    selectedCategoryIds.clear();
    selectedBrands.clear();
    searchText.value = "";
    searchedProducts.clear();
  }
}
