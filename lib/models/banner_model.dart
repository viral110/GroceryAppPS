import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String image;
  final String title;
  final int order;

  BannerModel({
    required this.id,
    required this.image,
    required this.title,
    required this.order,
  });

  factory BannerModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      image: data['image'] ?? '',
      title: data['title'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}
