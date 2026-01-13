import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/utils/product_pricing_extension.dart';

class ProductDetailController extends GetxController {
  final ProductModel product;

  ProductDetailController(this.product);

  /// Observables
  var selectedWeightIndex = 0.obs;
  var quantity = 1.obs;
  var totalPrice = 0.0.obs;

  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  // List<String> sortedPackaging = [];
  final RxList<String> sortedPackaging = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    sortedPackaging.value = product.sortedPackaging;

    if (sortedPackaging.isNotEmpty) {
      selectedWeightIndex.value = sortedPackaging.length - 1;
    } else {
      selectedWeightIndex.value = 0;
    }

    everAll([selectedWeightIndex, quantity], (_) => _updatePrice());
    _updatePrice();
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   sortedPackaging = product.sortedPackaging;
  //   selectedWeightIndex.value = sortedPackaging.length - 1;
  //   everAll([selectedWeightIndex, quantity], (_) => _updatePrice());
  //   _updatePrice();
  // }
  void _updatePrice() {
    if (sortedPackaging.isEmpty) {
      // Packet / Piece / Box
      totalPrice.value = product.price * quantity.value;
      return;
    }

    final packaging = sortedPackaging[selectedWeightIndex.value];
    totalPrice.value = product.unitPriceFor(packaging) * quantity.value;
  }

  // void _updatePrice() {
  //   final packaging = sortedPackaging[selectedWeightIndex.value];
  //   totalPrice.value = product.unitPriceFor(packaging) * quantity.value;
  // }

  String get selectedPackaging => sortedPackaging.isEmpty
      ? product.priceUnit
      : sortedPackaging[selectedWeightIndex.value];
  //sortedPackaging[selectedWeightIndex.value];

  double get unitPrice => sortedPackaging.isEmpty
      ? product.price
      : product.unitPriceFor(selectedPackaging);
  //product.unitPriceFor(selectedPackaging);

  double get multiplier =>
      sortedPackaging.isEmpty ? 1 : product.multiplierFor(selectedPackaging);
  // product.multiplierFor(selectedPackaging);

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
