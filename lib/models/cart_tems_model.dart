import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  String packaging;
  double multiplier; // e.g. 0.25, 1
  double unitPrice; // price for selected packaging (1 qty)

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.packaging,
    required this.multiplier,
    required this.unitPrice,
  });

  // double get discountedPrice =>
  //     product.price - (product.price * product.discount / 100);

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'packaging': packaging,
      'multiplier': multiplier,
      'unit_price': unitPrice,
      'quantity': quantity,

      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory CartItem.fromJson(ProductModel product, Map<String, dynamic> json) {
    return CartItem(
      product: product,
      quantity: json['quantity'] ?? 1,
      packaging: json['packaging'] ?? "1kg",
      multiplier: json['multiplier'] ?? 1.0,
      unitPrice: json['unit_price'] ?? 1.0,
    );
  }
}
