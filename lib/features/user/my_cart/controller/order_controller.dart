import 'dart:developer';
import 'dart:math' as mt;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/user/home/controller/home_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/view/order_success_view.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/services/razorpay_service.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../models/cart_tems_model.dart';
import '../../../admin/products/models/produce_model.dart';

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

  final RazorpayPaymentService _razorpayService =
      Get.find<RazorpayPaymentService>();

  /// ================= PROCESS RAZORPAY PAYMENT =================
  Future<bool> processRazorpayPayment() async {
    try {
      final user = UserService.getUserFromHive();

      // Open Razorpay checkout using service
      final success = await _razorpayService.openCheckout(
        amount: finalPayable,
        orderId: DateTime.now().millisecondsSinceEpoch
            .toString(), // Temporary order ID
        userName: '${user.firstName ?? ''} ${user.lastName ?? ''}',
        userEmail: user.email ?? 'user@example.com',
        userPhone: user.mobileNumber ?? '',
        description: 'Grocery App PS Order Payment',
        notes: {
          'user_id': userId,
          'cart_total': cartTotal.toString(),
          'discount': promoDiscount.value.toString(),
        },
        onSuccess: _handleRazorpaySuccess,
        onError: _handleRazorpayError,
        onExternalWallet: _handleRazorpayExternalWallet,
      );

      return success;
    } catch (e) {
      log('❌ Error processing Razorpay payment: $e');
      CommonToast.show('Failed to initialize payment', type: ToastType.error);
      return false;
    }
  }

  /// ================= RAZORPAY SUCCESS CALLBACK =================
  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    log('✅ Razorpay Payment Success in Controller');
    log('   Payment ID: ${response.paymentId}');

    try {
      CommonLoader.show();

      // Verify payment (should be done on backend in production)
      final isVerified = await _razorpayService.verifyPayment(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      );

      if (!isVerified) {
        CommonLoader.hide();
        CommonToast.show(
          'Payment verification failed. Contact support with Payment ID: ${response.paymentId}',
          type: ToastType.error,
        );
        return;
      }

      // Place order with payment details
      await placeOrder(
        paymentMethod: "Online",
        paymentId: response.paymentId,
        paymentSignature: response.signature,
      );

      // Save promo usage if applied
      await onOrderSuccess();

      CommonLoader.hide();
      CommonToast.show(
        'Payment successful! Your order has been placed.',
        type: ToastType.success,
      );
    } catch (e) {
      CommonLoader.hide();
      log('❌ Error handling payment success: $e');
      CommonToast.show(
        'Payment successful but order creation failed. Contact support with Payment ID: ${response.paymentId}',
        type: ToastType.error,
      );
    }
  }

  /// ================= RAZORPAY ERROR CALLBACK =================
  void _handleRazorpayError(PaymentFailureResponse response) {
    log('❌ Razorpay Payment Error in Controller');
    log('   Code: ${response.code}');
    log('   Message: ${response.message}');

    final errorMessage = _razorpayService.getPaymentErrorMessage(response);
    CommonToast.show(errorMessage, type: ToastType.error);
  }

  /// ================= RAZORPAY EXTERNAL WALLET CALLBACK =================
  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    log('💳 External Wallet Selected: ${response.walletName}');
    CommonToast.show(
      'Processing payment with ${response.walletName}',
      type: ToastType.info,
    );
  }

  Future<void> _decreaseStockAfterOrder(
    List<CartItem> cartItems,
    String storeId,
  ) async {
    await _firestore.runTransaction((transaction) async {
      /// ================= STEP 1: AGGREGATE REQUIRED QTY =================
      /// key = productId|packagingLabel
      final Map<String, int> requiredQtyMap = {};

      for (final item in cartItems) {
        if (item.quantity <= 0) continue;

        final key = '${item.product.id}|${item.packagingLabel}';
        requiredQtyMap[key] = (requiredQtyMap[key] ?? 0) + item.quantity;
      }

      /// ================= STEP 2: READ ALL UNIQUE PRODUCTS =================
      final Map<String, DocumentSnapshot> productSnaps = {};

      for (final key in requiredQtyMap.keys) {
        final productId = key.split('|').first;

        if (productSnaps.containsKey(productId)) continue;

        final ref = _firestore
            .collection(AppConstantStrings.productsCollection)
            .doc(productId);

        final snap = await transaction.get(ref);
        if (snap.exists) {
          productSnaps[productId] = snap;
        }
      }

      /// ================= STEP 3: UPDATE STOCK (SAFE WAY) =================
      /// ================= STEP 3: UPDATE STOCK (SAFE WAY) =================
      for (final entry in requiredQtyMap.entries) {
        final parts = entry.key.split('|');
        final productId = parts[0];
        final packagingLabel = parts[1];
        final requiredQty = entry.value;

        final snap = productSnaps[productId];
        if (snap == null) continue;

        final product = ProductModel.fromDoc(snap);

        final storeIndex = product.storeConfigs.indexWhere(
          (s) => s.storeId == storeId,
        );
        if (storeIndex == -1) continue;

        final storeConfig = product.storeConfigs[storeIndex];

        final packagingIndex = storeConfig.packaging.indexWhere(
          (p) => p.label == packagingLabel,
        );
        if (packagingIndex == -1) continue;

        final currentQty = storeConfig.packaging[packagingIndex].quantity;

        final newQty = (currentQty - requiredQty).clamp(0, currentQty);

        debugPrint(
          'STOCK UPDATE → '
          'Product:$productId | '
          'Pack:$packagingLabel | '
          'Old:$currentQty | '
          'Minus:$requiredQty | '
          'New:$newQty',
        );

        /// ✅ UPDATE IN MEMORY
        storeConfig.packaging[packagingIndex].quantity = newQty;

        /// ✅ WRITE FULL store_configs ARRAY (CRITICAL)
        transaction.update(snap.reference, {
          'store_configs': product.storeConfigs.map((e) => e.toJson()).toList(),
        });
      }
    });
  }

  String generateOrderCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = mt.Random();
    return 'ORD-' +
        List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// ================= GENERATE SEQUENTIAL ORDER ID =================
  /// Returns a sequential order ID like: ORD-000001, ORD-000002, etc.
  Future<String> _generateSequentialOrderId() async {
    final counterRef = _firestore
        .collection(AppConstantStrings.appMetaDataCollection)
        .doc('order_counter');

    String? generatedOrderId;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentCounter = 1;

      if (snapshot.exists) {
        currentCounter = (snapshot.data()?['counter'] ?? 0) + 1;
      }

      // Update counter
      transaction.set(counterRef, {
        'counter': currentCounter,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Generate order ID with padding (6 digits)
      generatedOrderId = 'ORD-${currentCounter.toString().padLeft(6, '0')}';
    });

    return generatedOrderId!;
  }

  /// ================= PLACE ORDER =================
  Future<void> placeOrder({
    required String paymentMethod,
    String? paymentId,
    String? paymentSignature,
  }) async {
    try {
      CommonLoader.show();
      isPlacingOrder.value = true;

      final cartController = Get.find<CartController>();
      final user = UserService.getUserFromHive();

      if (cartController.cartItems.isEmpty) {
        throw Exception("Cart is empty");
      }

      /// ================= GENERATE SEQUENTIAL ORDER ID =================
      final shortOrderId = await _generateSequentialOrderId();
      log('Generated Sequential Order ID: $shortOrderId');

      /// ================= CREATE ORDER DOC =================
      final orderDoc = _firestore
          .collection(AppConstantStrings.orderCollection)
          .doc();

      /// ================= BUILD ORDER ITEMS =================
      final orderItems = cartController.cartItems.map((item) {
        return OrderItemModel(
          productId: item.product.id,
          productName: item.product.name,
          unitValue: item.packagingLabel, // ✅ FIXED
          unitPrice: item.unitPrice,
          quantity: item.quantity,
          totalPrice: item.totalPrice,
          image: item.product.thumbnail,
        );
      }).toList();
      // final shortOrderId = generateOrderCode();

      /// ================= BUILD ORDER MODEL =================
      final order = OrderModel(
        orderId: orderDoc.id,
        userId: user.uid,
        shortOrderId: shortOrderId,
        deliveryDate: formattedDate,
        storeId: user.storeId,
        orderStatus: "Pending",
        paymentStatus: paymentMethod == "COD" ? "pending" : "paid",
        paymentMethod: paymentMethod,
        items: orderItems,
        subtotal: cartController.subtotal, // ✅ safer
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
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      /// Save last order (for success screen)
      lastOrder.value = order;

      /// ================= PREPARE DATA =================
      final Map<String, dynamic> orderData = order.toMap();

      /// Add payment info if online
      if (paymentMethod == "Online" && paymentId != null) {
        orderData.addAll({
          'payment_id': paymentId,
          'payment_signature': paymentSignature,
          'payment_completed_at': Timestamp.now(),
        });
      }

      await orderDoc.set(orderData);
      await _decreaseStockAfterOrder(cartController.cartItems, user.storeId);

      /// ================= CLEAR CART =================
      await _clearCart(cartController, user.uid);

      /// ================= RESET =================
      resetCheckout();
      final homeController = Get.find<HomeController>();
      await homeController.fetchProducts();
      Get.back(closeOverlays: true); // close checkout
      Get.to(
        () => OrderSuccessView(
          orderId: shortOrderId,
          paymentMethod: paymentMethod,
        ),
      );
      CommonToast.show("Order placed successfully", type: ToastType.success);
    } catch (e) {
      CommonToast.show(
        e.toString().replaceAll('Exception: ', ''),
        type: ToastType.error,
      );
      rethrow;
    } finally {
      CommonLoader.hide();
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
      final docId = "${item.product.id}_${item.packagingLabel}";
      batch.delete(cartRef.doc(docId));
    }

    await batch.commit();

    /// Clear local cart
    cartController.cartItems.clear();

    /// Reset checkout state
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

    final double creditToDeduct = creditToUse; // keep as double

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        throw Exception("User not found");
      }

      final data = snapshot.data()!;

      /// ✅ SAFE CONVERSION (INT OR DOUBLE)
      final double remainingCredit = (data['remaining_credits'] ?? 0)
          .toDouble();
      final double usedCredit = (data['used_credits'] ?? 0).toDouble();

      if (remainingCredit <= 0) {
        throw Exception("No credit available");
      }

      if (remainingCredit < creditToDeduct) {
        throw Exception("Insufficient credit balance");
      }

      /// ✅ ATOMIC UPDATE
      transaction.update(userRef, {
        'remaining_credits': remainingCredit - creditToDeduct,
        'used_credits': usedCredit + creditToDeduct,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });

    /// ✅ SYNC LOCAL USER (HIVE)
    user.remainingCredits =
        (user.remainingCredits ?? 0).toDouble() - creditToDeduct;
    user.usedCredits = (user.usedCredits ?? 0).toDouble() + creditToDeduct;

    await UserService.setUserInHive(user);
  }

  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  String get formattedDate {
    if (selectedDate.value == null) return "-";

    final date = selectedDate.value!;
    return DateFormat('dd MMM yyyy, EEEE').format(date);
  }
}
