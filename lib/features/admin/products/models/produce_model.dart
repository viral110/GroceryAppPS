import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;

  /// CATEGORY
  final String categoryId;
  final String categoryName;

  final String brand;
  final String priceUnit;
  final double price;
  final int stock;
  final String description;
  final String thumbnail;
  final List<String> images;
  final List<String> packaging;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.brand,
    required this.priceUnit,
    required this.price,
    required this.stock,
    required this.description,
    required this.thumbnail,
    required this.images,
    required this.packaging,
    required this.createdAt,
  });

  /// ================= TO FIRESTORE =================
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "category_id": categoryId,
      "category_name": categoryName,
      "brand": brand,
      "price_unit": priceUnit,
      "price": price,
      "stock": stock,
      "description": description,
      "thumbnail": thumbnail,
      "images": images,
      "packaging": packaging,
      "created_at": Timestamp.fromDate(createdAt),
    };
  }

  /// ================= FROM FIRESTORE =================
  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      categoryId: data['category_id'] ?? '',
      categoryName: data['category_name'] ?? '',
      brand: data['brand'] ?? '',
      priceUnit: data['price_unit'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: (data['stock'] ?? 0).toInt(),
      description: data['description'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      packaging: List<String>.from(data['packaging'] ?? []),
      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
