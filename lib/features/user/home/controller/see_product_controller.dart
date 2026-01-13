import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import '../../home/controller/home_controller.dart';

enum SeeAllType { exclusive, bestSelling, random }

class SeeAllProductsController extends GetxController {
  final SeeAllType type;

  SeeAllProductsController(this.type);

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadProducts());
    // loadProducts();
  }

  void loadProducts() {
    isLoading.value = true;
    CommonLoader.show();

    final homeController = Get.find<HomeController>();

    if (type == SeeAllType.exclusive) {
      products.assignAll(homeController.exclusiveOffers);
    } else if (type == SeeAllType.bestSelling) {
      products.assignAll(homeController.bestSelling);
    } else if (type == SeeAllType.random) {
      products.assignAll(homeController.randomProducts);
    }

    isLoading.value = false;
    CommonLoader.hide();
  }
}
