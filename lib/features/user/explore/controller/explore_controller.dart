import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/models/product_item_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

import '../../../../services/user_services.dart';

enum SortType {
  none,
  priceLowToHigh,
  priceHighToLow,
  nameAToZ,
  nameZToA,
}

class ExploreController extends GetxController {
  final searchController = TextEditingController();
  final searchText = "".obs;

  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  RxList<ProductModel> searchedProducts = <ProductModel>[].obs;

  RxSet<String> selectedCategoryIds = <String>{}.obs;
  RxSet<String> selectedBrands = <String>{}.obs;
  RxList<String> availableBrands = <String>[].obs;

  Rx<SortType> selectedSort = SortType.none.obs;

  final _firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCategories();
      fetchAllProducts();
    });

    searchController.addListener(() {
      onSearchChanged(searchController.text);
    });
  }

  bool get isSearching =>
      searchText.value.isNotEmpty ||
          selectedCategoryIds.isNotEmpty ||
          selectedBrands.isNotEmpty;

  // 🔍 SEARCH
  void onSearchChanged(String value) {
    searchText.value = value.trim();
    applyFilters();
  }

  // 🧠 MAIN FILTER LOGIC
  void applyFilters() {
    List<ProductModel> filtered = [...allProducts];

    // Search
    if (searchText.value.isNotEmpty) {
      filtered = filtered
          .where((p) =>
          p.name.toLowerCase().contains(searchText.value.toLowerCase()))
          .toList();
    }

    // Category
    if (selectedCategoryIds.isNotEmpty) {
      filtered = filtered
          .where((p) => selectedCategoryIds.contains(p.categoryId))
          .toList();
    }

    // Brand
    if (selectedBrands.isNotEmpty) {
      filtered =
          filtered.where((p) => selectedBrands.contains(p.brand)).toList();
    }
    double _getProductPrice(ProductModel product) {
      // 🔹 Find store config matching current user store
      final storeConfig = product.storeConfigs
          ?.firstWhereOrNull(
            (s) => s.storeId == UserService.getUserFromHive().storeId,
      );

      // 🔹 Find default packaging inside that store
      final defaultPack = storeConfig?.packaging
          .firstWhereOrNull((p) => p.isDefault);

      return defaultPack?.price ?? 0.0;
    }

    // Sorting
    switch (selectedSort.value) {
      case SortType.priceLowToHigh:
        filtered.sort(
              (a, b) => _getProductPrice(a).compareTo(_getProductPrice(b)),
        );
        break;

      case SortType.priceHighToLow:
        filtered.sort(
              (a, b) => _getProductPrice(b).compareTo(_getProductPrice(a)),
        );
        break;
      case SortType.nameAToZ:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.nameZToA:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortType.none:
        break;
    }

    searchedProducts.assignAll(filtered);
  }

  // 📦 FETCH CATEGORIES
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      CommonLoader.show();

      final snapshot = await _firestore
          .collection(AppConstantStrings.categoryCollection)
          .orderBy('created_at')
          .get();

      categories.value = snapshot.docs
          .map((doc) => CategoryModel.fromSnapshot(doc.id, doc.data()))
          .toList();
    } catch (e) {
      log("Category Error: $e");
    } finally {
      CommonLoader.hide();
      isLoading.value = false;
    }
  }

  // 🛒 FETCH PRODUCTS
  Future<void> fetchAllProducts() async {
    try {
      isLoading.value = true;
      CommonLoader.show();

      final snapshot = await _firestore
          .collection(AppConstantStrings.productsCollection)
          .get();

      allProducts.value =
          snapshot.docs.map((doc) => ProductModel.fromDoc(doc)).toList();

      _extractBrands();
      searchedProducts.assignAll(allProducts);
    } catch (e) {
      log("Product Error: $e");
    } finally {
      CommonLoader.hide();
      isLoading.value = false;
    }
  }

  // 🏷 CATEGORY BASED BRAND FILTER
  void _extractBrands() {
    List<ProductModel> baseList = selectedCategoryIds.isEmpty
        ? allProducts
        : allProducts
        .where((p) => selectedCategoryIds.contains(p.categoryId))
        .toList();

    availableBrands.assignAll(
      baseList
          .map((p) => p.brand)
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList(),
    );

    selectedBrands.removeWhere((b) => !availableBrands.contains(b));
  }

  // 🔁 TOGGLE CATEGORY
  void toggleCategory(String categoryId) {
    selectedCategoryIds.contains(categoryId)
        ? selectedCategoryIds.remove(categoryId)
        : selectedCategoryIds.add(categoryId);

    _extractBrands();
    applyFilters();
  }

  // 🔁 TOGGLE BRAND
  void toggleBrand(String brand) {
    selectedBrands.contains(brand)
        ? selectedBrands.remove(brand)
        : selectedBrands.add(brand);

    applyFilters();
  }

  // ❌ CLEAR ALL
  void clearFilters() {
    selectedCategoryIds.clear();
    selectedBrands.clear();
    selectedSort.value = SortType.none;
    searchText.value = "";
    searchedProducts.assignAll(allProducts);
    _extractBrands();
  }
}
