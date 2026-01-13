import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/my_orders/view/order_details_controller.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class OrderDetailsView extends StatelessWidget {
  final OrderModel order;

  OrderDetailsView({super.key, required this.order});
  late final OrderDetailsController controller = Get.put(
    OrderDetailsController(order),
  );
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.find<BottomNavController>().changeTab(4); // Orders tab index
        Get.offAll(() => MainScreen());
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: CommonAppBar(title: "Order Details"),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Stepper
              _buildOrderStatusStepper(),

              const SizedBox(height: 8),

              // Delivery Address
              _buildDeliveryAddress(),

              const SizedBox(height: 8),

              // Order Items
              _buildOrderItems(),

              const SizedBox(height: 8),

              // Payment Summary
              _buildPaymentSummary(),

              const SizedBox(height: 8),

              // Order Info
              _buildOrderInfo(),
              if (controller.canCancelOrder) _buildCancelOrderButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _confirmCancelOrder(Get.context!),
          child: const Text(
            "Cancel Order",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmCancelOrder(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ICON + TITLE
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Cancel Order",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// MESSAGE
                Text(
                  "Are you sure you want to cancel this order?",
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 6),
                Text(
                  "This action cannot be undone.",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 24),

                /// ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("No"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelOrder();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Yes, Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cancelOrder() async {
    try {
      await controller.cancelOrder();

      Get.snackbar(
        "Order Cancelled",
        "Your order has been cancelled successfully",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      Get.find<BottomNavController>().changeTab(4);
      Get.offAll(() => MainScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to cancel order. Please try again.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Widget _buildOrderStatusStepper() {
    final statuses = _getOrderStatuses();
    final currentIndex = _getCurrentStatusIndex();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderId ?? "-",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _statusChip(order.orderStatus),
            ],
          ),
          const SizedBox(height: 20),

          // Stepper
          Column(
            children: List.generate(statuses.length, (index) {
              final status = statuses[index];
              final isCompleted = index < currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == statuses.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Circle and Line
                  Column(
                    children: [
                      _buildStepCircle(
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        icon: status['icon'],
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          color: isCompleted
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Right side - Status info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: (isCompleted || isCurrent)
                                  ? Colors.black
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status['subtitle'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required bool isCompleted,
    required bool isCurrent,
    required IconData icon,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isCurrent
            ? AppColors.primary
            : Colors.grey.shade300,
        border: Border.all(
          color: isCompleted || isCurrent
              ? AppColors.primary
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Icon(
        isCompleted ? Icons.check : icon,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    final address = order.deliveryAddress;
    if (address == null) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Delivery Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address.name ?? "-",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            address.phone ?? "-",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            "${address.addressLine ?? ""}, ${address.city ?? ""}, ${address.pincode ?? ""}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Items (${order.items.length})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 24, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: item.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image_outlined,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.image_outlined,
                            color: Colors.grey.shade400,
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName ?? "-",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.unitValue ?? "-",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Qty: ${item.quantity}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "₹${item.totalPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Payment Summary",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceRow("Subtotal", order.subtotal),
          const SizedBox(height: 10),
          _buildPriceRow("Delivery Charge", order.deliveryCharge),
          if (order.discount > 0) ...[
            const SizedBox(height: 10),
            _buildPriceRow("Discount", -order.discount, isDiscount: true),
          ],
          Divider(height: 24, color: Colors.grey.shade300),
          _buildPriceRow(
            "Total Amount",
            order.totalAmount,
            isBold: true,
            fontSize: 16,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.paymentMethod ?? "Unknown",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                        ),
                      ),
                      Text(
                        order.paymentStatus ?? "Unknown",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isBold = false,
    bool isDiscount = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isDiscount ? Colors.green : Colors.grey.shade800,
          ),
        ),
        Text(
          "₹${amount.abs().toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isDiscount ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Order ID", order.orderId ?? "-"),
          const SizedBox(height: 10),
          _buildInfoRow(
            "Order Date",
            order.createdAt != null
                ? "${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}"
                : "-",
          ),
          if (order.appliedPromoCode != null) ...[
            const SizedBox(height: 10),
            _buildInfoRow("Promo Code", order.appliedPromoCode!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
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

  List<Map<String, dynamic>> _getOrderStatuses() {
    final status = order.orderStatus?.toLowerCase();

    if (status == "cancelled") {
      return [
        {
          'title': 'Order Placed',
          'subtitle': 'Your order has been placed',
          'icon': Icons.check_circle_outline,
        },
        {
          'title': 'Order Cancelled',
          'subtitle': 'Your order has been cancelled',
          'icon': Icons.cancel_outlined,
        },
      ];
    }

    return [
      {
        'title': 'Order Placed',
        'subtitle': 'We have received your order',
        'icon': Icons.check_circle_outline,
      },
      {
        'title': 'Order Confirmed',
        'subtitle': 'Your order is being prepared',
        'icon': Icons.assignment_turned_in_outlined,
      },
      {
        'title': 'Out for Delivery',
        'subtitle': 'Your order is on the way',
        'icon': Icons.local_shipping_outlined,
      },
      {
        'title': 'Delivered',
        'subtitle': 'Order delivered successfully',
        'icon': Icons.done_all,
      },
    ];
  }

  int _getCurrentStatusIndex() {
    final status = order.orderStatus?.toLowerCase();

    if (status == "cancelled") {
      return 1;
    }

    switch (status) {
      case "pending":
        return 0;
      case "ongoing":
        return 2;
      case "completed":
        return 3;
      default:
        return 0;
    }
  }
}
