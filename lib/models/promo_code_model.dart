import 'package:cloud_firestore/cloud_firestore.dart';

class PromoCodeModel {
  final String id;
  final String code;
  final String discountType;
  final int discountValue;
  final int minOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int usedCount;

  PromoCodeModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.startDate,
    required this.endDate,
    required this.usedCount,
  });

  factory PromoCodeModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromoCodeModel(
      id: doc.id,
      code: data['code'] ?? "",
      discountType: data['discountType'] ?? "",
      discountValue: data['discountValue'] ?? "",
      minOrderAmount: data['minOrderAmount'] ?? "",
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      usedCount: data['usedCount'] ?? 0,
    );
  }
}
