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
  RxString selectedPaymentMethod = "Select Method".obs;
  RxDouble discount = 0.0.obs;

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
        final String productId = doc.id;
        final int quantity = doc['quantity'];

        // Fetch product details
        final productDoc = await _firestore
            .collection(AppConstantStrings.productsCollection)
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final product = ProductModel.fromDoc(productDoc);
          cartItems.add(CartItem(product: product, quantity: quantity));
        }
      }
    } catch (e) {
      CommonToast.show('Failed to load cart', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= ADD TO CART =================
  Future<void> addToCart(ProductModel product, {int qty = 1}) async {
    try {
      isLoading.value = true;
      final index = cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (index != -1) {
        cartItems[index].quantity += qty;
        cartItems.refresh();
      } else {
        cartItems.add(CartItem(product: product, quantity: qty));
      }

      await _saveCartItem(product.id, qty);

      CommonToast.show("Added to Cart", type: ToastType.success);
    } catch (e) {
      CommonToast.show("Failed to add to cart", type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= FIRESTORE SAVE =================
  Future<void> _saveCartItem(String productId, int qty) async {
    if (_userId == null) return;

    final ref = _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(_userId)
        .collection(AppConstantStrings.cartCollection)
        .doc(productId);

    final snap = await ref.get();

    if (snap.exists) {
      await ref.update({'quantity': FieldValue.increment(qty)});
    } else {
      await ref.set({
        'product_id': productId,
        'quantity': qty,
        'added_at': Timestamp.now(),
      });
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

  void _updateQuantity(CartItem item) {
    _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(_userId)
        .collection(AppConstantStrings.cartCollection)
        .doc(item.product.id)
        .update({'quantity': item.quantity});
  }

  /// ================= REMOVE =================
  void removeItem(int index) {
    final productId = cartItems[index].product.id;
    cartItems.removeAt(index);

    _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(_userId)
        .collection(AppConstantStrings.cartCollection)
        .doc(productId)
        .delete();
  }

  /// ================= TOTAL =================
  double get totalPrice {
    double total = 0;
    for (final item in cartItems) {
      total += item.totalPrice;
    }

    if (discount.value > 0) total -= discount.value;
    return total;
  }

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
