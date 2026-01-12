import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isPlacingOrder = false.obs;
  RxBool isPromoApplied = false.obs;
  RxDouble promoDiscount = 0.0.obs;
  RxString appliedPromoCode = ''.obs;
  RxString appliedPromoId = ''.obs;

  /// CART DATA (PASSED FROM BOTTOMSHEET)
  double cartTotal = 0.0;
  String userId = '';
  RxString selectedPaymentMethod = "Select Method".obs;
  @override
  void onInit() {
    super.onInit();

    final cart = Get.find<CartController>();

    ever(cart.cartItems, (_) {
      if (cart.cartItems.isEmpty) {
        resetCheckout();
      }
    });
  }

  /// Allowed order statuses
  static const List<String> orderStatuses = [
    "Pending",
    "Ongoing",
    "Completed",
    "Cancelled",
  ];

  void initCheckout({required double total, required String uid}) {
    log("TOTAL: ${total}");
    cartTotal = total;
    log("CART TOTAL: ${cartTotal}");
    userId = uid;
    resetPromo();
  }

  Future<Map<String, dynamic>> applyPromoCode({
    required String promoCode,
    required double cartTotal,
    required String userId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    /// 1️⃣ FIND PROMO
    final promoQuery = await firestore
        .collection(AppConstantStrings.promoCodeCollection)
        .where('code', isEqualTo: promoCode.toUpperCase())
        // .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (promoQuery.docs.isEmpty) {
      CommonToast.show("Invalid promo code", type: ToastType.warning);
      throw Exception();
    }

    final promoDoc = promoQuery.docs.first;
    final promo = promoDoc.data();
    log("PROMO DATA: ${promo}");

    /// 2️⃣ CHECK DATE
    final now = DateTime.now();
    final startDate = (promo['startDate'] as Timestamp).toDate();
    final endDate = (promo['endDate'] as Timestamp).toDate();

    log("NOW: ${now}, START: ${startDate}, END: ${endDate}");
    if (now.isBefore(startDate) || now.isAfter(endDate)) {
      CommonToast.show("Promo code expired", type: ToastType.warning);
      throw Exception();
    }

    log("cartTotal: ${cartTotal}, minOrderAmount: ${promo['minOrderAmount']}");

    /// 3️⃣ MIN ORDER
    if (cartTotal < promo['minOrderAmount']) {
      log(
        "cartTotal: ${cartTotal}, minOrderAmount: ${promo['minOrderAmount']}",
      );
      CommonToast.show(
        "Minimum order ₹${promo['minOrderAmount']} required",
        type: ToastType.warning,
      );
      throw Exception();
    }

    /// 5️⃣ 🔥 USER ALREADY USED CHECK
    final usageId = "${promoDoc.id}_$userId";
    log(" USAGE ID: ${usageId}");
    final usageDoc = await firestore
        .collection('promo_usages')
        .doc(usageId)
        .get();
    log(" USAGE DOC: ${usageDoc.exists}");

    if (usageDoc.exists) {
      CommonToast.show(
        "You have already used this promo code",
        type: ToastType.warning,
      );
      throw Exception();
    }

    /// 6️⃣ CALCULATE DISCOUNT
    double discount = promo['discountType'] == 'flat'
        ? promo['discountValue'].toDouble()
        : (cartTotal * promo['discountValue'] / 100);
    log("applyDISOUNT: ${discount}");

    // return discount;
    return {'discount': discount, 'promoId': promoDoc.id};
  }

  Future<void> savePromoUsage({
    required String promoId,
    required String userId,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final usageId = "${promoId}_$userId";

    await firestore.runTransaction((transaction) async {
      final promoRef = firestore
          .collection(AppConstantStrings.promoCodeCollection)
          .doc(promoId);
      final usageRef = firestore.collection('promo_usages').doc(usageId);

      transaction.set(usageRef, {
        'promoId': promoId,
        'userId': userId,
        'usedAt': Timestamp.now(),
      });

      transaction.update(promoRef, {'usedCount': FieldValue.increment(1)});
    });
  }

  Future<void> applyPromo(String promoCode) async {
    try {
      CommonLoader.show();
      log("CART TOTAL INSIDE APPLY PROMO: ${cartTotal}");
      log("USER ID INSIDE APPLY PROMO: ${userId}");
      log("PROMO CODE INSIDE APPLY PROMO: ${promoCode}");
      final result = await applyPromoCode(
        promoCode: promoCode,
        cartTotal: cartTotal,
        userId: userId,
      );
      log("DISOUNT: ${result['discount']}");
      // ✅ SUCCESS

      promoDiscount.value = result['discount'];
      appliedPromoId.value = result['promoId']; // ✅ FIXED

      appliedPromoCode.value = promoCode.toUpperCase();
      isPromoApplied.value = true;
      // promoDiscount.value = discount;
      // isPromoApplied.value = true;
      // appliedPromoCode.value = promoCode.toUpperCase();
      // appliedPromoId.value = promoCode.toUpperCase();

      CommonToast.show(
        "You saved ₹${result['discount'].toStringAsFixed(0)}",
        type: ToastType.success,
      );
    } catch (_) {
      // handled internally
      resetPromo();
    } finally {
      CommonLoader.hide();
    }
  }

  void resetPromo() {
    isPromoApplied.value = false;
    promoDiscount.value = 0;
    appliedPromoCode.value = '';
    appliedPromoId.value = '';
  }

  double get finalPayable {
    final total = cartTotal - promoDiscount.value;
    return total < 0 ? 0 : total;
  }

  Rx<OrderModel?> lastOrder = Rx<OrderModel?>(null);

  /// ================= PLACE ORDER =================
  Future<void> placeOrder({required String paymentMethod}) async {
    try {
      isPlacingOrder.value = true;

      final cartController = Get.find<CartController>();
      final user = UserService.getUserFromHive();

      if (cartController.cartItems.isEmpty) {
        throw Exception("Cart is empty");
      }

      /// Create order document
      final orderDoc = _firestore
          .collection(AppConstantStrings.orderCollection)
          .doc();

      /// Build order items from cart
      final orderItems = cartController.cartItems.map((item) {
        return OrderItemModel(
          productId: item.product.id,
          productName: item.product.name,
          unitValue: item.packaging,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
          totalPrice: item.totalPrice,
          // isPromo: isPromoApplied.value,
          // promoPrice: promoDiscount.value,
          image: item.product.thumbnail,
        );
      }).toList();

      /// Build order model
      final order = OrderModel(
        orderId: orderDoc.id,
        userId: user.uid,
        storeId: user.storeId, // if available
        orderStatus: "Pending",
        paymentStatus: paymentMethod == "COD" ? "pending" : "paid",
        paymentMethod: paymentMethod,
        items: orderItems,
        subtotal: cartTotal,
        discount: promoDiscount.value,
        appliedPromoCode: appliedPromoCode.value,
        totalAmount: finalPayable,

        deliveryCharge: 0,
        deliveryAddress: DeliveryAddressModel(
          city: user.city,
          addressLine: user.area,
          name: '${user.firstName ?? ''} ${user.lastName ?? ''}',
          phone: user.mobileNumber,
          pincode: user.pincode,
        ), // DeliveryAddressModel
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      /// 🔥 ADD THIS LINE
      lastOrder.value = order;
      log(" ORDER DATA: ${lastOrder.value}");

      /// Save order
      await orderDoc.set(order.toMap());

      /// Clear cart (Firestore + local)
      await _clearCart(cartController, user.uid);

      /// 🔥 RESET ORDER STATE
      resetCheckout();
      CommonToast.show("Order placed successfully", type: ToastType.success);
    } catch (e) {
      CommonToast.show(
        e.toString().replaceAll('Exception: ', ''),
        type: ToastType.error,
      );
      rethrow;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> onOrderSuccess() async {
    if (isPromoApplied.value) {
      await savePromoUsage(promoId: appliedPromoId.value, userId: userId);
    }
  }

  /// ================= CHANGE ORDER STATUS =================
  Future<void> updateOrderStatus(String orderId, String status) async {
    if (!orderStatuses.contains(status)) {
      throw Exception("Invalid order status");
    }

    final orderRef = _firestore
        .collection(AppConstantStrings.orderCollection)
        .doc(orderId);

    await orderRef.update({
      'orderStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ================= CLEAR CART =================
  Future<void> _clearCart(CartController cartController, String userId) async {
    final cartRef = _firestore
        .collection(AppConstantStrings.userCollection)
        .doc(userId)
        .collection(AppConstantStrings.cartCollection);

    final batch = _firestore.batch();

    for (final item in cartController.cartItems) {
      batch.delete(cartRef.doc(item.product.id + item.packaging));
    }

    await batch.commit();

    cartController.cartItems.clear();
    // cartController.discount.value = 0;
    selectedPaymentMethod.value = "Select Method";
  }

  void resetCheckout() {
    cartTotal = 0.0;
    userId = '';
    resetPromo();
  }

  Future<void> payUsingCredit(double creditToUse) async {
    final user = UserService.getUserFromHive();
    final userRef = FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      final data = snapshot.data() ?? {};

      final int totalCredit = (data['credit'] ?? 0).toInt();
      final int spentCredit = data['used_credits'] ?? 0;

      final int remainingCredit = totalCredit - spentCredit;

      if (remainingCredit <= 0) {
        throw Exception("No credit available");
      }

      if (remainingCredit < creditToUse) {
        throw Exception("Insufficient credit balance");
      }

      transaction.update(userRef, {
        'used_credits': spentCredit + creditToUse.toInt(),
        'update_at': FieldValue.serverTimestamp(),
      });
    });
    user.usedCredits = ((user.usedCredits ?? 0) + creditToUse).toInt();
    await UserService.setUserInHive(user);
  }
}
