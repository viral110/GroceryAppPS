import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/my_orders/view/order_details_view.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = UserService.getUserFromHive().uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "My Orders"),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(AppConstantStrings.orderCollection)
            .where('user_id', isEqualTo: userId)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!.docs
              .map((doc) => OrderModel.fromMap(doc.data()))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) => _orderCard(orders[index]),
          );
        },
      ),
    );
  }
}

Widget _orderCard(OrderModel order) {
  return GestureDetector(
    onTap: () => Get.to(() => OrderDetailsView(order: order)),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ORDER ID + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.shortOrderId ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              _statusChip(order.orderStatus),
            ],
          ),

          const SizedBox(height: 8),

          /// DATE
          Text(
            order.createdAt != null
                ? "${order.createdAt!.day}-${order.createdAt!.month}-${order.createdAt!.year}"
                : "-",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),

          const SizedBox(height: 12),

          /// TOTAL + VIEW DETAILS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${AppConstantStrings.rupeeSymbol} ${order.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => OrderDetailsView(order: order));
                },

                child: Text(
                  "View Details",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _statusChip(String? status) {
  Color bgColor = Colors.grey.shade200;
  Color textColor = Colors.grey.shade800;
  String displayText = status ?? "Unknown";

  switch (status?.toLowerCase()) {
    case "pending":
      bgColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orange;
      displayText = "Pending";
      break;
    case "ongoing":
      bgColor = Colors.blue.withOpacity(0.15);
      textColor = Colors.blue;
      displayText = "Ongoing";
      break;
    case "completed":
      bgColor = AppColors.primary.withOpacity(0.15);
      textColor = AppColors.primary;
      displayText = "Completed";
      break;
    case "cancelled":
      bgColor = Colors.red.withOpacity(0.15);
      textColor = Colors.red;
      displayText = "Cancelled";
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      displayText,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    ),
  );
}
