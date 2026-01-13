import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';


class OrderDetailView extends StatelessWidget {
  final String orderId;

  const OrderDetailView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.whiteColor,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // WEB WIDTH
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("orders")
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

  // ---------------- ORDER HEADER ----------------
  Widget _orderHeader(OrderModel order) {
    return _card(
      Column(
        children: [
          _row("Order ID", order.orderId),
          _row("Order Status", order.orderStatus),
          _row("Payment Method", order.paymentMethod),
          _row("Payment Status", order.paymentStatus),
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

  // ---------------- ITEMS ----------------
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
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w600,
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

  // ---------------- PRICE ----------------
  Widget _priceSection(OrderModel order) {
    return _card(
      Column(
        children: [
          _priceRow("Subtotal", order.subtotal),
          _priceRow("Delivery Charge", order.deliveryCharge),
          _priceRow("Discount", -order.discount),
          const Divider(),
          _priceRow(
            "Total Amount",
            order.totalAmount,
            isBold: true,
          ),
        ],
      ),
    );
  }

  // ---------------- ADDRESS ----------------
  Widget _addressSection(OrderModel order) {
    final a = order.deliveryAddress!;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  // ---------------- COMMON WIDGETS ----------------
  Widget _card(Widget child) {
    return Card(
      color: AppColors.whiteColor,
      elevation: 2,
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
              color: AppColors.textColor,
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
        color: AppColors.textColor,
      ),
    );
  }

  TextStyle get _normalText =>
      const TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w500);

  TextStyle get _grayText =>
      const TextStyle(color: AppColors.grayTextColor);
}
