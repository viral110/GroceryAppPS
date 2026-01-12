import 'package:cloud_firestore/cloud_firestore.dart';
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

  String? get _userId => UserService.getUserFromHive().uid;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_userId != null) {
      loadCart();
    }
  }

  /// ================= LOAD CART =================
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      cartItems.clear();

      final cartSnap = await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(_userId)
          .collection(AppConstantStrings.cartCollection)
          .get();

      for (final doc in cartSnap.docs) {
        final data = doc.data();

        final productDoc = await _firestore
            .collection(AppConstantStrings.productsCollection)
            .doc(data['product_id'])
            .get();

        if (productDoc.exists) {
          final product = ProductModel.fromDoc(productDoc);

          cartItems.add(CartItem.fromJson(product, data));
        }
      }
    } catch (e) {
      CommonToast.show('Failed to load cart', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  // CartController
  double get subtotal {
    double total = 0;
    for (final item in cartItems) {
      total += item.totalPrice;
    }
    return total;
  }

  /// ================= ADD TO CART =================
  Future<void> addToCart({
    required ProductModel product,
    required String packaging,
    required double multiplier,
    required double unitPrice,
    int quantity = 1,
  }) async {
    try {
      isLoading.value = true;
      final index = cartItems.indexWhere(
        (item) => item.product.id == product.id && item.packaging == packaging,
      );

      if (index != -1) {
        cartItems[index].quantity += quantity;
        cartItems.refresh();

        await _firestore
            .collection(AppConstantStrings.userCollection)
            .doc(_userId)
            .collection(AppConstantStrings.cartCollection)
            .doc(cartItems[index].product.id + packaging)
            .update({'quantity': cartItems[index].quantity});
      } else {
        final cartItem = CartItem(
          product: product,
          packaging: packaging,
          multiplier: multiplier,
          unitPrice: unitPrice,
          quantity: quantity,
        );
        cartItems.add(cartItem);
        await _firestore
            .collection(AppConstantStrings.userCollection)
            .doc(_userId)
            .collection(AppConstantStrings.cartCollection)
            .doc(product.id + packaging) // UNIQUE PER WEIGHT
            .set(cartItem.toJson());
      }

      // await _saveCartItem(product.id, qty);

      CommonToast.show("Added to Cart", type: ToastType.success);
    } catch (e) {
      CommonToast.show("Failed to add to cart", type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= QUANTITY =================
  void increment(int index) {
    cartItems[index].quantity++;
    cartItems.refresh();
    _updateQuantity(cartItems[index]);
  }

  void decrement(int index) {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
      _updateQuantity(cartItems[index]);
    } else {
      removeItem(index);
    }
  }

  Future<void> _updateQuantity(CartItem item) async {
    final docId = item.product.id + item.packaging;
    await _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(_userId)
        .collection(AppConstantStrings.cartCollection)
        .doc(docId)
        .update({'quantity': item.quantity});
  }

  /// ================= REMOVE =================
  void removeItem(int index) {
    final item = cartItems[index];
    final docId = item.product.id + item.packaging;

    cartItems.removeAt(index);

    _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(_userId)
        .collection(AppConstantStrings.cartCollection)
        .doc(docId)
        .delete();
  }

  void oldremoveItem(int index) {
    final productId = cartItems[index].product.id;
    cartItems.removeAt(index);

    _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(_userId)
        .collection(AppConstantStrings.cartCollection)
        .doc(productId)
        .delete();
  }

  // /// ================= TOTAL =================
  // double get totalPrice {
  //   double total = 0;
  //   for (final item in cartItems) {
  //     total += item.totalPrice;
  //   }
  //   // if (discount.value > 0) total -= discount.value;
  //   return total;
  // }

  /// ================= CLEAR =================
  // Future<void> clearCart() async {
  //   final batch = _firestore.batch();
  //   final cartRef = _firestore
  //       .collection('AppConstantStrings.userCollection')
  //       .doc(_userId)
  //       .collection('cart');
  //   final snap = await cartRef.get();
  //   for (final doc in snap.docs) {
  //     batch.delete(doc.reference);
  //   }
  //   await batch.commit();
  //   cartItems.clear();
  //   discount.value = 0;
  //   selectedPaymentMethod.value = "Select Method";
  // }
}
