import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_groceries_app/features/admin/store_manage/models/store_model.dart';

class ProductModel {
  final String id;
  final String name;

  final String categoryId;
  final int kps;
  final int discount;
  final String categoryName;
  final String brand;
  final String priceUnit;
  final double price;
  final String description;
  final String thumbnail;
  final List<String> images;
  final List<String> packaging;
  final List<StoreStockModel> storeStocks;

  final DateTime createdAt;

  ProductModel( {
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.brand,
    required this.priceUnit,
    required this.price,
    required this.description,
    required this.thumbnail,
    required this.images,
    required this.packaging,
    required this.storeStocks,
    required this.createdAt,
    required this.kps
    , required this.discount,
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
      "description": description,
      "thumbnail": thumbnail,
      "images": images,
      "packaging": packaging,
      "discount": discount,
      "kps": kps,

      "store_stock": storeStocks.map((e) => e.toJson()).toList(),

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
      description: data['description'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      packaging: List<String>.from(data['packaging'] ?? []),
      discount: data['discount'] ?? 0,
      kps:data['kps'] ?? 0 ,

      /// ✅ FULL STORE REBUILD
      storeStocks: (data['store_stock'] as List? ?? [])
          .map((e) => StoreStockModel.fromJson(e))
          .toList(),



      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class StoreStockModel {
  final String storeId;
  final String storeName;
  int stock;

  StoreStockModel({
    required this.storeId,
    required this.storeName,
    required this.stock,
  });

  factory StoreStockModel.fromJson(Map<String, dynamic> json) {
    return StoreStockModel(
      storeId: (json['store_id'] ?? '').toString(),
      storeName: (json['store_name'] ?? '').toString(),
      stock: (json['stock'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    "store_id": storeId,
    "store_name": storeName,
    "stock": stock,
  };
}
