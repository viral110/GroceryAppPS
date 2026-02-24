import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/user/help/controller/customer_support_controller.dart';
import 'package:online_groceries_app/features/user/help/view/customer_support.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/models/support_model.dart';
import 'package:online_groceries_app/services/pdf_invoice_service.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AdminOrdersController extends GetxController {
  RxInt selectedTab = 0.obs;
  RxString searchQuery = ''.obs;
  RxBool isDownloading = false.obs;

  final List<String> tabs = [
    "All",
    "New Requests",
    "Ongoing",
    "Completed",
    "Cancelled",
  ];

  final List<String> orderStatusList = [
    "Pending",
    "Ongoing",
    "Completed",
    "Cancelled",
  ];

  final List<String> paymentStaus = ['paid', 'pending'];

  Query get ordersQuery {
    Query query = FirebaseFirestore.instance.collection(
      AppConstantStrings.orderCollection,
    );
    switch (selectedTab.value) {
      case 1:
        query = query.where('order_status', isEqualTo: 'Pending');
        break;
      case 2:
        query = query.where('order_status', isEqualTo: 'Ongoing');
        break;
      case 3:
        query = query.where('order_status', isEqualTo: 'Completed');
        break;
      case 4:
        query = query.where('order_status', isEqualTo: 'Cancelled');
        break;
    }
    query = query.orderBy('created_at', descending: true);
    return query;
  }

  void changeTab(int index) {
    selectedTab.value = index;
    searchQuery.value = '';
  }

  void updateSearch(String value) {
    searchQuery.value = value.toLowerCase().trim();
  }

  List<OrderModel> filterOrders(List<OrderModel> orders, String query) {
    if (query.isEmpty) return orders;

    final lowerQuery = query.toLowerCase();

    return orders.where((order) {
      // Search in Order ID (both full and short)
      // final orderId = order.orderId?.toLowerCase() ?? '';
      final shortOrderId = order.shortOrderId?.toLowerCase() ?? '';

      // Search in Customer Details
      final customerName = order.deliveryAddress?.name?.toLowerCase() ?? '';
      // final customerPhone = order.deliveryAddress?.phone?.toLowerCase() ?? '';

      // Search in Items (product names)
      final itemsText = order.items
          .map((item) => item.productName?.toLowerCase() ?? '')
          .join(' ');

      // Search in Payment Method
      final paymentMethod = order.paymentMethod?.toLowerCase() ?? '';

      // Return true if query matches any field
      return
      // orderId.contains(lowerQuery) ||
      shortOrderId.contains(lowerQuery) ||
          customerName.contains(lowerQuery) ||
          // customerPhone.contains(lowerQuery) ||
          itemsText.contains(lowerQuery) ||
          paymentMethod.contains(lowerQuery);
    }).toList();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstantStrings.orderCollection)
        .where('order_id', isEqualTo: orderId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'order_status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updatePaymentStaus({
    required String orderId,
    required String paymentStatus,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstantStrings.orderCollection)
        .where('order_id', isEqualTo: orderId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'payment_status': paymentStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Download invoice PDF for an order
  Future<void> downloadInvoice(OrderModel order) async {
    try {
      isDownloading.value = true;

      final controller = Get.find<CustomerSupportController>();

      SupportModel support;
      if (controller.support.value != null) {
        support = controller.support.value!;
      } else {
        support = SupportModel(email: '', phone: '');
      }

      // For web platform
      final pdf = await PdfInvoiceService.createInvoicePDF(order, support);
      final pdfBytes = await pdf.save();
      await PdfInvoiceService.downloadPdf(
        pdfBytes,
        'Invoice_${order.shortOrderId ?? DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      CommonToast.show(
        'Invoice downloaded successfully',
        type: ToastType.success,
      );
    } catch (e) {
      CommonToast.show('Failed to download invoice', type: ToastType.error);
    } finally {
      isDownloading.value = false;
    }
  }
}
