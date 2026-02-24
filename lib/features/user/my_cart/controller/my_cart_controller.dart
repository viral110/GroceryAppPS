import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/models/cart_tems_model.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var cartItems = <CartItem>[].obs;
  RxBool isLoading = false.obs;

  String? get _userId => UserService.getUserFromHive().uid;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userId != null) {
        loadCart();
      }
    });
  }

  /// ================= LOAD CART =================
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      CommonLoader.show();
      cartItems.clear();
      final cartSnap = await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(_userId)
          .collection(AppConstantStrings.cartCollection)
          .get();

      final productIds = cartSnap.docs
          .map((e) => e['product_id'] as String)
          .toSet()
          .toList();

      if (productIds.isEmpty) {
        cartItems.clear();
        isLoading.value = false;
        CommonLoader.hide();
        return;
      }
      final productSnap = await _firestore
          .collection(AppConstantStrings.productsCollection)
          .where(FieldPath.documentId, whereIn: productIds)
          .get();

      final productMap = {
        for (var doc in productSnap.docs) doc.id: ProductModel.fromDoc(doc),
      };

      for (final doc in cartSnap.docs) {
        final product = productMap[doc['product_id']];
        if (product == null) continue;

        final cartItem = CartItem.fromJson(product, doc.data());
        cartItems.add(cartItem);
      }

      // ✅ Sort cart items alphabetically by product name
      cartItems.sort((a, b) => a.product.name.compareTo(b.product.name));

      // for (final doc in cartSnap.docs) {
      //   final data = doc.data();
      //   final productDoc = await _firestore
      //       .collection(AppConstantStrings.productsCollection)
      //       .doc(data['product_id'])
      //       .get();
      //   if (!productDoc.exists) continue;
      //   final product = ProductModel.fromDoc(productDoc);
      //   /// ✅ CREATE CART ITEM FIRST
      //   final cartItem = CartItem.fromJson(product, data);
      //   /// 🔹 CHECK AVAILABLE STOCK
      //   final availableStock = _getAvailableStock(
      //     product,
      //     cartItem.packagingLabel,
      //   );
      //   /// ❌ SOLD OUT → REMOVE
      //   if (availableStock <= 0) {
      //     await _firestore
      //         .collection(AppConstantStrings.userCollection)
      //         .doc(_userId)
      //         .collection(AppConstantStrings.cartCollection)
      //         .doc("${product.id}_${cartItem.packagingLabel}")
      //         .delete();
      //     continue;
      //   }
      //   /// ⚠️ REDUCE QTY IF STOCK LOW
      //   if (cartItem.quantity > availableStock) {
      //     cartItem.quantity = availableStock;
      //     await _firestore
      //         .collection(AppConstantStrings.userCollection)
      //         .doc(_userId)
      //         .collection(AppConstantStrings.cartCollection)
      //         .doc("${product.id}_${cartItem.packagingLabel}")
      //         .update({'quantity': availableStock});
      //   }
      //   cartItems.add(cartItem);
      // }
    } catch (e) {
      log("FAILED TO LOAD CART: ${e.toString()}");
      CommonToast.show('Failed to load cart', type: ToastType.error);
    } finally {
      CommonLoader.hide();
      isLoading.value = false;
    }
  }

  /// ================= SUBTOTAL =================
  double get subtotal {
    double total = 0;
    for (final item in cartItems) {
      total += item.totalPrice;
    }
    return total;
  }

  int _getAvailableStock(ProductModel product, String packagingLabel) {
    try {
      final storeId = UserService.getUserFromHive().storeId;

      final storeConfig = product.storeConfigs.firstWhereOrNull(
        (s) => s.storeId == storeId,
      );

      final packaging = storeConfig?.packaging.firstWhereOrNull((p) {
        print("PRODUCTSS");
        print(p.label);
        return p.label == packagingLabel;
      });

      return packaging?.quantity ?? 0;
    } catch (e, s) {
      print(e);
      print(s);
      return 0;
    }
  }

  Future<void> addToCart({
    required ProductModel product,
    required PackagingModel packaging,
    required double unitPrice,
    int quantity = 1,
  }) async {
    try {
      isLoading.value = true;
      final int availableStock = _getAvailableStock(product, packaging.label);
      if (availableStock <= 0) {
        CommonToast.show("Product is Sold Out", type: ToastType.error);
        return;
      }

      final index = cartItems.indexWhere(
        (item) =>
            item.product.id == product.id &&
            item.packagingLabel == packaging.label,
      );

      final int currentQty = index != -1 ? cartItems[index].quantity : 0;

      if (currentQty + quantity > availableStock) {
        CommonToast.show(
          "Only $availableStock item(s) available",
          type: ToastType.error,
        );
        return;
      }

      // final int discount = packaging.discount;
      // final double discountedUnitPrice = discount > 0
      //     ? unitPrice - (unitPrice * discount / 100)
      //     : unitPrice;

      final docId = "${product.id}_${packaging.label}";

      if (index != -1) {
        cartItems[index].quantity += quantity;
        cartItems.refresh();

        // ✅ Sort after update
        cartItems.sort((a, b) => a.product.name.compareTo(b.product.name));
        cartItems.refresh();

        await _firestore
            .collection(AppConstantStrings.userCollection)
            .doc(_userId)
            .collection(AppConstantStrings.cartCollection)
            .doc(docId)
            .update({'quantity': cartItems[index].quantity});
      } else {
        final cartItem = CartItem(
          product: product,
          packagingLabel: packaging.label,
          multiplier: 1,
          unitPrice: unitPrice,
          quantity: quantity,
        );

        cartItems.add(cartItem);

        await _firestore
            .collection(AppConstantStrings.userCollection)
            .doc(_userId)
            .collection(AppConstantStrings.cartCollection)
            .doc(docId)
            .set(cartItem.toJson());
      }

      CommonToast.show("Added to Cart", type: ToastType.success);
    } catch (e) {
      CommonToast.show("Failed to add to cart", type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= QUANTITY =================
  void increment(int index) {
    final item = cartItems[index];

    final availableStock = _getAvailableStock(
      item.product,
      item.packagingLabel,
    );

    if (item.quantity >= availableStock) {
      CommonToast.show(
        "Only $availableStock item(s) available",
        type: ToastType.error,
      );
      return;
    }

    item.quantity++;
    cartItems.refresh();
    _updateQuantity(item);
  }

  Future<void> decrement(int index) async {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
      _updateQuantity(cartItems[index]);
    } else {
      await removeItem(index);
    }
  }

  Future<void> _updateQuantity(CartItem item) async {
    final docId = "${item.product.id}_${item.packagingLabel}";
    await _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(_userId)
        .collection(AppConstantStrings.cartCollection)
        .doc(docId)
        .update({'quantity': item.quantity});
  }

  /// ================= REMOVE ITEM =================
  Future<void> removeItem(int index) async {
    try {
      final item = cartItems[index];
      final docId = "${item.product.id}_${item.packagingLabel}";

      cartItems.removeAt(index);
      await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(_userId)
          .collection(AppConstantStrings.cartCollection)
          .doc(docId)
          .delete();
    } catch (e) {
      log("REMOVE ERRRO: ${e.toString()}");
    }
  }
}
