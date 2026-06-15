import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/services/user_services.dart';

class ProductDetailController extends GetxController {
  final ProductModel product;

  ProductDetailController(this.product);

  List<String> get sortedPackaging =>
      packagingList.map((p) => p.label).toList();

  final RxInt selectedWeightIndex = 0.obs;
  final RxInt quantity = 1.obs;
  final RxDouble totalPrice = 0.0.obs;

  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  /// ================= PACKAGING =================
  late final List<PackagingModel> packagingList;

  int get availableStock => selectedPackaging.quantity ?? 0;
  bool get isSoldOut => availableStock <= 0;

  PackagingModel get selectedPackaging =>
      packagingList[selectedWeightIndex.value];

  double get unitPrice => selectedPackaging.price;
  int get discount => selectedPackaging.discount;
  bool get isLowStock => availableStock > 0 && availableStock <= 5;

  // ✅ Calculate discounted selling price
  double get sellingPrice {
    if (discount > 0) {
      return unitPrice - (unitPrice * discount / 100);
    }
    return unitPrice;
  }

  /// ================= INIT =================
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    String? selectedPackagingLabel;
    int? cartQuantity;

    if (args != null) {
      selectedPackagingLabel = args["packagingLabel"];
      cartQuantity = args["quantity"];
      if (cartQuantity != null) {
        quantity.value = cartQuantity;
      }
    }

    /// 🔹 store config
    final storeConfig = product.storeConfigs.firstWhereOrNull(
          (s) => s.storeId == UserService.getUserFromHive().storeId,
    );

    if (storeConfig == null && product.storeConfigs.isNotEmpty) {
      packagingList = product.storeConfigs.first.packaging;
    } else if (storeConfig != null) {
      packagingList = storeConfig.packaging;
    } else {
      packagingList = [];
    }

    if (packagingList.isEmpty) return;

    /// ✅ Only packaging selection from cart
    if (selectedPackagingLabel != null) {
      final index = packagingList.indexWhere(
            (p) => p.label == selectedPackagingLabel,
      );

      selectedWeightIndex.value =
      index != -1 ? index : 0;
    } else {
      /// 🔹 default logic
      final defaultIndex =
      packagingList.indexWhere((p) => p.isDefault);

      selectedWeightIndex.value =
      defaultIndex != -1 ? defaultIndex : 0;
    }

    everAll([selectedWeightIndex, quantity], (_) {
      _updateTotalPrice();
    });

    _updateTotalPrice();
  }

  /// ================= PRICE CALC =================
  void _updateTotalPrice() {
    if (isSoldOut) {
      totalPrice.value = 0.0;
      return;
    }

    // ✅ Use selling price (after discount)
    totalPrice.value = sellingPrice * quantity.value;
  }

  /// ================= ACTIONS =================
  void incrementQuantity() {
    if (isSoldOut) {
      CommonToast.show("Product is sold out", type: ToastType.error);
      return;
    }

    if (quantity.value >= availableStock) {
      CommonToast.show(
        "Only $availableStock item(s) available",
        type: ToastType.warning,
      );
      return;
    }

    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void selectWeight(int index) {
    selectedWeightIndex.value = index;
    quantity.value = 1; // reset on packaging change
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
