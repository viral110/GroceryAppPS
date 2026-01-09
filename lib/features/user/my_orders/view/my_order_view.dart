import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:CommonAppBar(title: "My Orders"),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: myOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return _orderCard(myOrders[index]);
        },
      ),
    );
  }
}
class OrderModel {
  final String orderId;
  final String date;
  final String total;
  final OrderStatus status;

  OrderModel({
    required this.orderId,
    required this.date,
    required this.total,
    required this.status,
  });
}

enum OrderStatus { delivered, pending, cancelled }
final List<OrderModel> myOrders = [
  OrderModel(
    orderId: "#ORD12345",
    date: "12 Jan 2026",
    total: "\$25.50",
    status: OrderStatus.delivered,
  ),
  OrderModel(
    orderId: "#ORD12346",
    date: "14 Jan 2026",
    total: "\$18.99",
    status: OrderStatus.pending,
  ),
  OrderModel(
    orderId: "#ORD12347",
    date: "18 Jan 2026",
    total: "\$42.00",
    status: OrderStatus.cancelled,
  ),
];
Widget _orderCard(OrderModel order) {
  return Container(
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
              order.orderId,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            _statusChip(order.status),
          ],
        ),

        const SizedBox(height: 8),

        /// DATE
        Text(
          order.date,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 12),

        /// TOTAL + VIEW DETAILS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              order.total,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Get.to(() => OrderDetailsView());
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
  );
}
Widget _statusChip(OrderStatus status) {
  Color bgColor;
  Color textColor;
  String text;

  switch (status) {
    case OrderStatus.delivered:
      bgColor = AppColors.primary.withOpacity(0.15);
      textColor = AppColors.primary;
      text = "Delivered";
      break;

    case OrderStatus.pending:
      bgColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orange;
      text = "Pending";
      break;

    case OrderStatus.cancelled:
      bgColor = Colors.red.withOpacity(0.15);
      textColor = Colors.red;
      text = "Cancelled";
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    ),
  );
}


