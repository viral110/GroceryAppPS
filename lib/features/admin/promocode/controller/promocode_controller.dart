import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class PromoController extends GetxController {
  RxString searchQuery = ''.obs;

  Stream<List<PromoModel>> getPromos() {
    return FirebaseFirestore.instance
        .collection(AppConstantStrings.promocodesCollection)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((e) => PromoModel.fromJson(e)).toList());
  }


  void onSearch(String value) {
    searchQuery.value = value.toLowerCase();
  }

  List<PromoModel> filterPromos(List<PromoModel> promos) {
    if (searchQuery.value.isEmpty) return promos;

    return promos
        .where(
          (p) => p.code.toLowerCase().contains(searchQuery.value),
    )
        .toList();
  }



  Future<void> deletePromo(String id) async {
    await FirebaseFirestore.instance
        .collection(AppConstantStrings.promocodesCollection)
        .doc(id)
        .delete();
  }
}

class PromoModel {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final int usedCount;
  final DateTime startDate;
  final DateTime endDate;

  PromoModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
  });

  factory PromoModel.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PromoModel(
      id: doc.id,
      code: data['code'] ?? '',
      discountType: data['discountType'] ?? 'flat',
      discountValue: (data['discountValue'] ?? 0).toDouble(),
      minOrderAmount: (data['minOrderAmount'] ?? 0).toDouble(),
      usedCount: data['usedCount'] ?? 0,
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 30)),
    );
  }
}



