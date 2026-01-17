// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:online_groceries_app/features/admin/store_manage/models/store_model.dart';
//
// class ProductModel {
//   final String id;
//   final String name;
//
//   /// CATEGORY
//   final String categoryId;
//   final String sku;
//   final int discount;
//   final String categoryName;
//
//   final String brand;
//   final String priceUnit;
//   final double price;
//   final String description;
//   final String thumbnail;
//   final List<String> images;
//   final List<String> packaging;
//   final List<StoreStockModel> storeStocks;
//
//   final DateTime createdAt;
//   final List<String>? storeIds;
//
//
//   ProductModel( {
//     required this.id,
//     required this.name,
//     required this.categoryId,
//     required this.categoryName,
//     required this.brand,
//     required this.priceUnit,
//     required this.price,
//     required this.description,
//     required this.thumbnail,
//     required this.images,
//     required this.packaging,
//     required this.storeStocks,
//     required this.createdAt,
//     required this.sku,
//     required this.discount,
//
//     this.storeIds,
//   });
//
//   /// ================= TO FIRESTORE =================
//   Map<String, dynamic> toJson() {
//     return {
//       "name": name,
//       "category_id": categoryId,
//       "category_name": categoryName,
//       "brand": brand,
//       "price_unit": priceUnit,
//       "price": price,
//       "description": description,
//       "thumbnail": thumbnail,
//       "images": images,
//       "packaging": packaging,
//       "discount": discount,
//       "sku": sku,
//       "store_stock": storeStocks.map((e) => e.toJson()).toList(),
//       "store_ids": storeStocks.map((e) => e.storeId).toSet().toList(),
//       "created_at": Timestamp.fromDate(createdAt),
//     };
//   }
//
//   /// ================= FROM FIRESTORE =================
//   factory ProductModel.fromDoc(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//
//     return ProductModel(
//       id: doc.id,
//       name: data['name'] ?? '',
//       categoryId: data['category_id'] ?? '',
//       categoryName: data['category_name'] ?? '',
//       brand: data['brand'] ?? '',
//       priceUnit: data['price_unit'] ?? '',
//       price: (data['price'] ?? 0).toDouble(),
//       description: data['description'] ?? '',
//       thumbnail: data['thumbnail'] ?? '',
//       images: List<String>.from(data['images'] ?? []),
//       packaging: List<String>.from(data['packaging'] ?? []),
//       discount: data['discount'] ?? 0,
//       sku:data['sku'] ?? 0 ,
//       storeIds: List<String>.from(data['store_ids'] ?? []),
//       /// ✅ FULL STORE REBUILD
//       storeStocks: (data['store_stock'] as List? ?? [])
//           .map((e) => StoreStockModel.fromJson(e))
//           .toList(),
//
//       createdAt: data['created_at'] is Timestamp
//           ? (data['created_at'] as Timestamp).toDate()
//           : DateTime.now(),
//     );
//   }
// }
//
// class StoreStockModel {
//   final String storeId;
//   final String storeName;
//   int stock;
//
//   StoreStockModel({
//     required this.storeId,
//     required this.storeName,
//     required this.stock,
//   });
//
//   factory StoreStockModel.fromJson(Map<String, dynamic> json) {
//     return StoreStockModel(
//       storeId: (json['store_id'] ?? '').toString(),
//       storeName: (json['store_name'] ?? '').toString(),
//       stock: (json['stock'] ?? 0).toInt(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "store_id": storeId,
//     "store_name": storeName,
//     "stock": stock,
//   };
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;

  /// CATEGORY
  final String categoryId;
  final String categoryName;

  /// BASIC INFO
  final String brand;
  final String description;

  /// MEDIA
  final String thumbnail;
  final List<String> images;

  /// STORE-WISE CONFIG
  final List<StoreProductConfig> storeConfigs;

  /// META
  final DateTime createdAt;
  final List<String> storeIds;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.brand,
    required this.description,
    required this.thumbnail,
    required this.images,
    required this.storeConfigs,
    required this.createdAt,
    required this.storeIds,
  });

  /// ================= TO FIRESTORE =================
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "category_id": categoryId,
      "category_name": categoryName,
      "brand": brand,
      "description": description,
      "thumbnail": thumbnail,
      "images": images,
      "store_configs": storeConfigs.map((e) => e.toJson()).toList(),
      "store_ids": storeIds,
      "created_at": Timestamp.fromDate(createdAt),
    };
  }

  /// ================= FROM FIRESTORE =================
  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final storeConfigs = (data['store_configs'] as List? ?? [])
        .map((e) => StoreProductConfig.fromJson(e))
        .toList();

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      categoryId: data['category_id'] ?? '',
      categoryName: data['category_name'] ?? '',
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      storeConfigs: storeConfigs,
      storeIds:
      storeConfigs.map((e) => e.storeId).toSet().toList(),
      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class PackagingModel {
   String label; // e.g. 250g, 500g, 1kg
   double price;
   String sku;
   int discount;
   int quantity;
   bool isDefault;

  PackagingModel({
    required this.label,
    required this.price,
    required this.sku,
    required this.discount,
    required this.quantity,
    this.isDefault = false,
  });

  factory PackagingModel.fromJson(Map<String, dynamic> json) {
    return PackagingModel(
      label: json['label'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      sku: json['sku'] ?? '',
      discount: json['discount'] ?? 0,
      quantity: json['quantity'] ?? 0,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "label": label,
    "price": price,
    "sku": sku,
    "discount": discount,
    "quantity": quantity,
    "isDefault": isDefault,
  };
}
class StoreProductConfig {
   String storeId;
   String storeName;
   String unit; // Kg / Gram / Packet
   List<PackagingModel> packaging;
   TextEditingController? tempPackagingController;

  StoreProductConfig({
    required this.storeId,
    required this.storeName,
    required this.unit,
    required this.packaging,
  }){
    tempPackagingController = TextEditingController();
  }

  factory StoreProductConfig.fromJson(Map<String, dynamic> json) {
    return StoreProductConfig(
      storeId: json['store_id'] ?? '',
      storeName: json['store_name'] ?? '',
      unit: json['unit'] ?? '',
      packaging: (json['packaging'] as List? ?? [])
          .map((e) => PackagingModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "store_id": storeId,
    "store_name": storeName,
    "unit": unit,
    "packaging": packaging.map((e) => e.toJson()).toList(),
  };
}
