import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteModel {
  final String productId;
  final DateTime addedAt;

  FavouriteModel({required this.productId, required this.addedAt});

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'added_at': Timestamp.fromDate(addedAt)};
  }

  factory FavouriteModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavouriteModel(
      productId: data['product_id'] ?? '',
      addedAt: data['added_at'] is Timestamp
          ? (data['added_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
