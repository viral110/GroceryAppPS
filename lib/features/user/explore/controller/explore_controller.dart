import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  final searchController = TextEditingController();
  final searchText = "".obs;

  void onSearchChanged(String value) {
    searchText.value = value;
  }

  bool get isSearching => searchText.value.isNotEmpty;
}
class ProductItem {
  final String name;
  final String image;
  final String price;

  ProductItem({
    required this.name,
    required this.image,
    required this.price,
  });
}
final List<ProductItem> products = [
  ProductItem(
    name: "Egg Chicken Red",
    image: "assets/png/category/fruits.png",
    price: "₹1.99",
  ),
  ProductItem(
    name: "Egg Chicken White",
    image: "assets/png/category/meat.png",
    price: "₹1.50",
  ),
  ProductItem(
    name: "Egg Pasta",
    image: "assets/png/category/meat.png",
    price: "₹15.99",
  ),
];

