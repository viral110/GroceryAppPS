import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get discountedPrice =>
      product.price - (product.price * product.discount / 100);

  double get totalPrice => discountedPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'name': product.name,
      'price': product.price,
      'discount': product.discount,
      'thumbnail': product.thumbnail,
      'price_unit': product.priceUnit,
      'quantity': quantity,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json, ProductModel product) {
    return CartItem(product: product, quantity: json['quantity'] ?? 1);
  }
}
