import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.createdAt,
  });

  factory CategoryModel.fromSnapshot(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['image_url'] ?? '',
      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  // factory CategoryModel.fromDoc(Map<String, dynamic> data, String id) {
  //   return CategoryModel(
  //     id: id,
  //     name: data['name'] ?? '',
  //     imageUrl: data['image_url'] ?? '',
  //     createdAt: (data['created_at'] as Timestamp).toDate(),
  //   );
  // }
}

// class CategoryModel {
//   final String id;
//   final String name;
//   final String imageUrl;
//   final DateTime? createdAt;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.imageUrl,
//     this.createdAt,
//   });

//   factory CategoryModel.fromFirestore(
//     DocumentSnapshot<Map<String, dynamic>> doc,
//   ) {
//     final data = doc.data()!;

//     return CategoryModel(
//       id: doc.id,
//       name: data['name'] ?? '',
//       imageUrl: data['image_url'] ?? '',
//       createdAt: (data['created_at'] as Timestamp?)?.toDate(),
//     );
//   }
// }
