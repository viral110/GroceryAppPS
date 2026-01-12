import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';

class ProductDetailController extends GetxController {
  final ProductModel product;

  ProductDetailController(this.product);

  /// Observables
  var selectedWeightIndex = 0.obs;
  var quantity = 1.obs;
  var totalPrice = 0.0.obs;

  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  late final List<String> sortedPackaging;
  @override
  void onInit() {
    super.onInit();

    /// Sort ONCE
    sortedPackaging = List.from(product.packaging)
      ..sort((a, b) => _getMultiplier(a).compareTo(_getMultiplier(b)));

    /// Default → largest unit (usually 1kg)
    selectedWeightIndex.value = sortedPackaging.length - 1;

    _updatePrice();
    // React to changes in weight or quantity
    everAll([selectedWeightIndex, quantity], (_) => _updatePrice());
  }

  void _updatePrice() {
    // base price per unit
    double basePrice = product.price;

    // If packaging has a multiplier (like "250 gm" = 0.25kg)

    final selectedPackage = sortedPackaging[selectedWeightIndex.value];
    double multiplier = _getMultiplier(selectedPackage);

    totalPrice.value = (basePrice * multiplier * quantity.value);
  }

  // List<String> get sortedPackaging {
  //   List<String> list = List.from(product.packaging);
  //   list.sort((a, b) {
  //     double wA = _getMultiplier(a);
  //     double wB = _getMultiplier(b);
  //     return wA.compareTo(wB); // ascending
  //   });
  //   return list;
  // }

  double _getMultiplier(String packagingLabel) {
    if (packagingLabel.toLowerCase().contains("kg")) {
      return double.tryParse(
            packagingLabel.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          1.0;
    } else if (packagingLabel.toLowerCase().contains("g")) {
      return (double.tryParse(
                packagingLabel.replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0) /
          1000;
    }
    return 1.0;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  void selectWeight(int index) {
    selectedWeightIndex.value = index;
    quantity.value = 1; // reset quantity on weight change
  }
}
