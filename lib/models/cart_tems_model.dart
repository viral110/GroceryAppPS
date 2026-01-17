import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  String packagingLabel; // ✅ FIXED
  double multiplier;
  double unitPrice;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.packagingLabel,
    required this.multiplier,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'packaging': packagingLabel,
      'multiplier': multiplier,
      'unit_price': unitPrice,
      'quantity': quantity,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory CartItem.fromJson(ProductModel product, Map<String, dynamic> json) {
    return CartItem(
      product: product,
      quantity: json['quantity'] ?? 1,
      packagingLabel: json['packaging'] ?? '',
      multiplier: (json['multiplier'] ?? 1).toDouble(),
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }
}
