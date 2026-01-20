import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

enum SortType { none, priceLowToHigh, priceHighToLow, nameAToZ, nameZToA }

class SubcategoryController extends GetxController {
  final String categoryId; // Selected category
  SubcategoryController(this.categoryId);

  // ✅ All products from this category
  var allProducts = <ProductModel>[].obs;

  // ✅ Filtered/sorted products to display
  var products = <ProductModel>[].obs;

  var isLoading = false.obs;

  // ✅ Filter states
  RxSet<String> selectedBrands = <String>{}.obs;
  RxList<String> availableBrands = <String>[].obs;
  Rx<SortType> selectedSort = SortType.none.obs;

  @override
  void onInit() {
    super.onInit();
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
          .where(
            'store_ids',
            arrayContains: UserService.getUserFromHive().storeId,
          )
          // .orderBy('created_at', descending: true)
          .get();

      allProducts.value = snapshot.docs
          .map((doc) => ProductModel.fromDoc(doc))
          .toList();

      // ✅ Extract available brands
      _extractBrands();

      // ✅ Initially show all products
      products.assignAll(allProducts);
    } catch (e) {
      log("Error fetching products: $e");
    } finally {
      CommonLoader.hide();
      isLoading.value = false;
    }
  }

  // ✅ Extract unique brands from products
  void _extractBrands() {
    availableBrands.assignAll(
      allProducts
          .map((p) => p.brand)
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList(),
    );
  }

  // ✅ Get product price for sorting
  double _getProductPrice(ProductModel product) {
    final storeConfig = product.storeConfigs?.firstWhereOrNull(
      (s) => s.storeId == UserService.getUserFromHive().storeId,
    );

    final defaultPack = storeConfig?.packaging.firstWhereOrNull(
      (p) => p.isDefault,
    );

    final double mrp = defaultPack?.price ?? 0.0;
    final int discount = defaultPack?.discount ?? 0;

    return discount > 0 ? mrp - (mrp * discount / 100) : mrp;
  }

  // ✅ Apply filters and sorting
  void applyFilters() {
    List<ProductModel> filtered = [...allProducts];

    // Brand filter
    if (selectedBrands.isNotEmpty) {
      filtered = filtered
          .where((p) => selectedBrands.contains(p.brand))
          .toList();
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

    products.assignAll(filtered);
  }

  // ✅ Toggle brand selection
  void toggleBrand(String brand) {
    if (selectedBrands.contains(brand)) {
      selectedBrands.remove(brand);
    } else {
      selectedBrands.add(brand);
    }
    applyFilters();
  }

  // ✅ Clear all filters
  void clearFilters() {
    selectedBrands.clear();
    selectedSort.value = SortType.none;
    products.assignAll(allProducts);
  }
}
