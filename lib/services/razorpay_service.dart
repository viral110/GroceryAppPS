import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';

class RazorpayPaymentService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;

  // Observable for keys
  final RxString keyId = ''.obs;
  final RxBool isEnabled = true.obs;
  final RxBool isTestMode = true.obs;
  final RxBool isLoading = false.obs;

  // Callbacks
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    loadRazorpayConfig();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  /// ================= INITIALIZE RAZORPAY =================
  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// ================= LOAD CONFIG FROM FIREBASE =================
  Future<void> loadRazorpayConfig() async {
    try {
      isLoading.value = true;

      final doc = await _firestore
          .collection(AppConstantStrings.appConfigCollection)
          .doc('razorpay')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        keyId.value = data['key_id'] ?? '';
        isEnabled.value = data['enabled'] ?? false;
        isTestMode.value = data['test_mode'] ?? false;

        log('✅ Razorpay Config Loaded:');
        log('   Key ID: ${keyId.value}');
        log('   Enabled: ${isEnabled.value}');
        log('   Test Mode: ${isTestMode.value}');
      } else {
        log('⚠️ Razorpay config not found in Firebase');
        CommonToast.show(
          'Payment configuration not found',
          type: ToastType.error,
        );
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      log('❌ Error loading Razorpay config: $e');
      CommonToast.show(
        'Failed to load payment configuration',
        type: ToastType.error,
      );
    }
  }

  /// ================= OPEN RAZORPAY CHECKOUT =================
  Future<bool> openCheckout({
    required double amount,
    required String orderId,
    required String userName,
    required String userEmail,
    required String userPhone,
    String description = 'Order Payment',
    Map<String, dynamic>? notes,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) async {
    try {
      // Validation checks
      if (!isEnabled.value) {
        CommonToast.show(
          'Online payment is currently unavailable',
          type: ToastType.error,
        );
        return false;
      }

      if (keyId.value.isEmpty) {
        CommonToast.show(
          'Payment gateway not configured',
          type: ToastType.error,
        );
        return false;
      }

      // Store callbacks
      _onSuccess = onSuccess;
      _onError = onError;
      _onExternalWallet = onExternalWallet;

      // Convert amount to paise (Razorpay uses smallest currency unit)
      final amountInPaise = (amount * 100).toInt();

      // Razorpay options
      final options = {
        'key': keyId.value,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'Groceries App PS',
        'description': description,
        'timeout': 300,
        'prefill': {'contact': userPhone, 'email': userEmail, 'name': userName},
        'notes': notes ?? {},
        'theme': {'color': '#ff4f00'},
      };

      // final options = {
      //   'key': keyId.value,
      //   'amount': amountInPaise,
      //   'name': 'Online Groceries App',
      //   'order_id': orderId,
      //   'description': description,
      //   'timeout': 300, // 5 minutes in seconds
      //   'prefill': {'contact': userPhone, 'email': userEmail, 'name': userName},
      // 'theme': {
      //   'color': AppColors.primary, //'#53B175', // Your app's primary color
      // },
      //   'notes': notes ?? {'order_id': orderId},
      //   'retry': {'enabled': true, 'max_count': 3},
      //   'send_sms_hash': true,
      //   'remember_customer': true,
      //   'readonly': {'email': false, 'contact': false, 'name': false},
      // };

      log('🚀 Opening Razorpay checkout with amount: ₹$amount');
      _razorpay.open(options);
      return true;
    } catch (e) {
      log('❌ Error opening Razorpay checkout: $e');
      CommonToast.show('Failed to open payment gateway', type: ToastType.error);
      return false;
    }
  }

  /// ================= PAYMENT SUCCESS HANDLER =================
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('✅ Payment Success:');
    log('   Payment ID: ${response.paymentId}');
    log('   Order ID: ${response.orderId}');
    log('   Signature: ${response.signature}');

    if (_onSuccess != null) {
      _onSuccess!(response);
    } else {
      // Default behavior if no callback provided
      CommonToast.show('Payment successful', type: ToastType.success);
    }
  }

  /// ================= PAYMENT ERROR HANDLER =================
  void _handlePaymentError(PaymentFailureResponse response) {
    log('❌ Payment Error:');
    log('   Code: ${response.code}');
    log('   Message: ${response.message}');

    if (_onError != null) {
      _onError!(response);
    } else {
      // Default behavior if no callback provided
      String errorMessage = 'Payment failed';

      if (response.code == Razorpay.PAYMENT_CANCELLED) {
        errorMessage = 'Payment was cancelled';
      } else if (response.code == Razorpay.NETWORK_ERROR) {
        errorMessage = 'Network error. Please check your connection';
      } else {
        errorMessage = response.message ?? 'Payment failed';
      }

      CommonToast.show(errorMessage, type: ToastType.error);
    }
  }

  /// ================= EXTERNAL WALLET HANDLER =================
  void _handleExternalWallet(ExternalWalletResponse response) {
    log('💳 External Wallet Selected: ${response.walletName}');

    if (_onExternalWallet != null) {
      _onExternalWallet!(response);
    } else {
      CommonToast.show(
        'Payment with ${response.walletName}',
        type: ToastType.info,
      );
    }
  }

  /// ================= VERIFY PAYMENT (Backend) =================
  /// This should be called from your backend server
  /// For now, it's a placeholder - DO NOT use in production without backend verification
  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      // TODO: Call your backend API to verify payment
      // The backend should use key_secret to verify signature

      // Example backend call:
      // final response = await http.post(
      //   Uri.parse('YOUR_BACKEND_URL/verify-payment'),
      //   body: {
      //     'payment_id': paymentId,
      //     'order_id': orderId,
      //     'signature': signature,
      //   },
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return data['verified'] == true;
      // }

      log('⚠️ WARNING: Payment verification should be done on backend!');
      log('   Payment ID: $paymentId');
      log('   Order ID: $orderId');
      log('   Signature: $signature');

      // For testing purposes, return true
      // In production, MUST verify on backend
      return true;
    } catch (e) {
      log('❌ Error verifying payment: $e');
      return false;
    }
  }

  /// ================= CREATE RAZORPAY ORDER (Optional) =================
  /// If you want to create order on Razorpay server first
  /// This requires backend implementation
  Future<String?> createRazorpayOrder({
    required double amount,
    required String receiptId,
    Map<String, dynamic>? notes,
  }) async {
    try {
      // TODO: Call your backend to create Razorpay order
      // Backend should use Razorpay Orders API

      // Example:
      // final response = await http.post(
      //   Uri.parse('YOUR_BACKEND_URL/create-razorpay-order'),
      //   body: {
      //     'amount': (amount * 100).toString(), // in paise
      //     'receipt': receiptId,
      //     'notes': jsonEncode(notes ?? {}),
      //   },
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return data['order_id'];
      // }

      log('⚠️ Create Razorpay Order not implemented');
      return null;
    } catch (e) {
      log('❌ Error creating Razorpay order: $e');
      return null;
    }
  }

  /// ================= HELPER: Get Payment Error Message =================
  String getPaymentErrorMessage(PaymentFailureResponse response) {
    switch (response.code) {
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment was cancelled by user';
      case Razorpay.NETWORK_ERROR:
        return 'Network error. Please check your internet connection';
      default:
        return response.message ?? 'Payment failed. Please try again';
    }
  }
}
