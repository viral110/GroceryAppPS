import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AdminOrderDetailView extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailView({super.key, required this.orderId});

  // ORDER & PAYMENT OPTIONS
  static const List<String> orderStatuses = [
    "Pending",
    "Ongoing",
    "Completed",
    "Cancelled",
  ];

  static const List<String> paymentStatuses = [
    "pending",
    "paid",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: CommonAppBar(title: "Order Details"),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection(AppConstantStrings.orderCollection)
                .doc(orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final order = OrderModel.fromMap(
                snapshot.data!.data() as Map<String, dynamic>,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _orderHeader(order),
                    const SizedBox(height: 20),
                    _itemsSection(order),
                    const SizedBox(height: 20),
                    _priceSection(order),
                    const SizedBox(height: 20),
                    if (order.deliveryAddress != null)
                      _addressSection(order),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ================= ORDER HEADER =================
  Widget _orderHeader(OrderModel order) {
    final bool isEditable =
        order.orderStatus != "Completed" &&
            order.orderStatus != "Cancelled";

    return _card(
      Column(
        children: [
          _row("Order ID", order.orderId),

          /// ORDER STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order Status", style: _grayText),
              isEditable
                  ? _dropdown(
                value: order.orderStatus,
                items: orderStatuses,
                onChanged: (val) {
                  _updateStatus(
                    field: "order_status",
                    value: val,
                  );
                },
              )
                  : _statusText(order.orderStatus),
            ],
          ),

          /// PAYMENT STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Payment Status", style: _grayText),
              isEditable
                  ? _dropdown(
                value: order.paymentStatus,
                items: paymentStatuses,
                onChanged: (val) {
                  _updateStatus(
                    field: "payment_status",
                    value: val,
                  );
                },
              )
                  : _statusText(order.paymentStatus),
            ],
          ),

          _row("Payment Method", order.paymentMethod),

          _row(
            "Created At",
            order.createdAt != null
                ? DateFormat("dd MMM yyyy, hh:mm a")
                .format(order.createdAt!)
                : "-",
          ),
        ],
      ),
    );
  }

  // ================= ITEMS =================
  Widget _itemsSection(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title("Items"),
        const SizedBox(height: 10),
        ...order.items.map(
              (item) => _card(
            Row(
              children: [
                if (item.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item.image!,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Icon(Icons.shopping_bag, size: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.unitValue} × ${item.quantity}",
                        style: const TextStyle(
                          color: AppColors.grayTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹${item.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= PRICE =================
  Widget _priceSection(OrderModel order) {
    return _card(
      Column(
        children: [
          _priceRow("Subtotal", order.subtotal),
          _priceRow("Delivery Charge", order.deliveryCharge),
          _priceRow("Discount", -order.discount),
          const Divider(),
          _priceRow("Total Amount", order.totalAmount, isBold: true),
        ],
      ),
    );
  }

  // ================= ADDRESS =================
  Widget _addressSection(OrderModel order) {
    final a = order.deliveryAddress!;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: Get.width,),
          _title("Delivery Address"),
          const SizedBox(height: 8),
          Text(a.name ?? "", style: _normalText),
          Text(a.phone ?? "", style: _grayText),
          Text(a.addressLine ?? "", style: _grayText),
          Text("${a.city} - ${a.pincode}", style: _grayText),
        ],
      ),
    );
  }

  // ================= DROPDOWN =================
  Widget _dropdown({
    required String? value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      focusColor: Colors.transparent,
      icon: Icon(Icons.keyboard_arrow_down_sharp),
      padding: EdgeInsets.zero,
      items: items
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(
            e,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _statusColor(e),
            ),
          ),
        ),
      )
          .toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }

  Future<void> _updateStatus({
    required String field,
    required String value,
  }) async {
    await FirebaseFirestore.instance
        .collection(AppConstantStrings.orderCollection)
        .doc(orderId)
        .update({
      field: value,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // ================= HELPERS =================
  Widget _card(Widget child) {
    return Card(
      elevation: 2,
      color: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }

  Widget _row(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _grayText),
          Text(value ?? "-", style: _normalText),
        ],
      ),
    );
  }

  Widget _priceRow(String title, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _grayText),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _statusText(String? status) {
    return Text(
      status ?? "-",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: _statusColor(status),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Ongoing":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      case "paid":
        return Colors.green;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  TextStyle get _normalText =>
      const TextStyle(fontWeight: FontWeight.w500);

  TextStyle get _grayText =>
      const TextStyle(color: AppColors.grayTextColor);
}
