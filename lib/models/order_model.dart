import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? orderId;
  final String? shortOrderId;
  final String? userId;
  final String? storeId;
  final String? orderStatus; // "Pending","Ongoing","Completed","Cancelled",
  final String? paymentStatus;
  final String? paymentMethod; // "COD","Credit","Online"
  final String? appliedPromoCode;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double totalAmount;
  final double squaredOffAmount; // ✅ NEW: Track how much has been squared off
  final DeliveryAddressModel? deliveryAddress;
  final String? deliveryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.orderId,
    this.shortOrderId,
    this.userId,
    this.storeId,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.appliedPromoCode,
    this.deliveryDate,
    this.items = const [],
    this.subtotal = 0.0,
    this.deliveryCharge = 0.0,
    this.discount = 0.0,
    this.totalAmount = 0.0,
    this.squaredOffAmount = 0.0, // ✅ Default to 0
    this.deliveryAddress,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return OrderModel();

    return OrderModel(
      orderId: map['order_id'],
      shortOrderId: map['short_order_id'],
      userId: map['user_id'],
      storeId: map['store_id'],
      orderStatus: map['order_status'],
      paymentStatus: map['payment_status'],
      deliveryDate: map['delivery_date'],
      paymentMethod: map['payment_method'],
      appliedPromoCode: map['applied_promo_code'],
      items:
          (map['items'] as List?)
              ?.map((e) => OrderItemModel.fromMap(e))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryCharge: (map['delivery_charge'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
      squaredOffAmount:
          (map['squared_off_amount'] as num?)?.toDouble() ?? 0.0, // ✅ NEW
      deliveryAddress: map['delivery_address'] != null
          ? DeliveryAddressModel.fromMap(map['delivery_address'])
          : null,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (orderId != null) 'order_id': orderId,
      if (shortOrderId != null) 'short_order_id': shortOrderId,
      if (userId != null) 'user_id': userId,
      if (storeId != null) 'store_id': storeId,
      if (orderStatus != null) 'order_status': orderStatus,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (appliedPromoCode != null) 'applied_promo_code': appliedPromoCode,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'delivery_charge': deliveryCharge,
      'discount': discount,
      'delivery_date': deliveryDate,
      'total_amount': totalAmount,
      'squared_off_amount': squaredOffAmount, // ✅ NEW
      if (deliveryAddress != null) 'delivery_address': deliveryAddress!.toMap(),
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class OrderItemModel {
  final String? productId;
  final String? productName;
  final String? unitValue; // "1 kg", "500 gm", "2 pcs"
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  // final bool isPromo;
  // final double? promoPrice;
  final String? image;

  OrderItemModel({
    this.productId,
    this.productName,
    this.unitValue,
    this.unitPrice = 0.0,
    this.quantity = 0,
    this.totalPrice = 0.0,
    // this.isPromo = false,
    // this.promoPrice,
    this.image,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return OrderItemModel();

    return OrderItemModel(
      productId: map['product_id'],
      productName: map['product_name'],
      unitValue: map['unit_value'],
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0,
      quantity: map['quantity'] ?? 0,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      // isPromo: map['is_promo'] ?? false,
      // promoPrice: (map['promo_price'] as num?)?.toDouble(),
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (unitValue != null) 'unit_value': unitValue,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      // 'is_promo': isPromo,
      // if (promoPrice != null) 'promo_price': promoPrice,
      if (image != null) 'image': image,
    };
  }
}

class DeliveryAddressModel {
  final String? name;
  final String? phone;
  final String? addressLine;
  final String? city;
  final String? pincode;

  DeliveryAddressModel({
    this.name,
    this.phone,
    this.addressLine,
    this.city,
    this.pincode,
  });

  factory DeliveryAddressModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return DeliveryAddressModel();

    return DeliveryAddressModel(
      name: map['name'],
      phone: map['phone'],
      addressLine: map['address_line'],
      city: map['city'],
      pincode: map['pincode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (addressLine != null) 'address_line': addressLine,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
    };
  }
}
