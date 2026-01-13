import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class OrderDetailsController extends GetxController {
  final OrderModel order;

  OrderDetailsController(this.order);

  bool get canCancelOrder {
    final status = order.orderStatus?.toLowerCase();
    log("ORDER STATUS: $status");
    return status == "Pending" ||
        status == "Ongoing" ||
        status == "pending" ||
        status == "ongoing";
  }

  Future<void> cancelOrder() async {
    final orderId = order.orderId;
    if (orderId == null) return;

    await FirebaseFirestore.instance
        .collection(AppConstantStrings.orderCollection)
        .doc(orderId)
        .update({
          'order_status': 'Cancelled',
          'updated_at': FieldValue.serverTimestamp(),
        });
  }
}
