import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/services/product_pricing_extension.dart';

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

    sortedPackaging = product.sortedPackaging;
    selectedWeightIndex.value = sortedPackaging.length - 1;

    everAll([selectedWeightIndex, quantity], (_) => _updatePrice());
    _updatePrice();
  }

  void _updatePrice() {
    final packaging = sortedPackaging[selectedWeightIndex.value];
    totalPrice.value = product.unitPriceFor(packaging) * quantity.value;
  }
  // void _updatePrice() {
  //   // base price per unit
  //   double basePrice = product.price;
  //   // If packaging has a multiplier (like "250 gm" = 0.25kg)
  //   final selectedPackage = sortedPackaging[selectedWeightIndex.value];
  //   double multiplier = _getMultiplier(selectedPackage);
  //   totalPrice.value = (basePrice * multiplier * quantity.value);
  // }

  // String get selectedPackaging => sortedPackaging[selectedWeightIndex.value];

  // double get selectedMultiplier => _getMultiplier(selectedPackaging);

  // double get unitPrice => product.price * selectedMultiplier;
  String get selectedPackaging => sortedPackaging[selectedWeightIndex.value];

  double get unitPrice => product.unitPriceFor(selectedPackaging);

  double get multiplier => product.multiplierFor(selectedPackaging);

  // double _getMultiplier(String packagingLabel) {
  //   if (packagingLabel.toLowerCase().contains("kg")) {
  //     return double.tryParse(
  //           packagingLabel.replaceAll(RegExp(r'[^0-9.]'), ''),
  //         ) ??
  //         1.0;
  //   } else if (packagingLabel.toLowerCase().contains("g")) {
  //     return (double.tryParse(
  //               packagingLabel.replaceAll(RegExp(r'[^0-9.]'), ''),
  //             ) ??
  //             0) /
  //         1000;
  //   }
  //   return 1.0;
  // }

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
