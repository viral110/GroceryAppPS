import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/models/promo_code_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class PromoCodeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<PromoCodeModel> promoCodes = <PromoCodeModel>[].obs;

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchPromoCodes());
    // fetchPromoCodes();
    super.onInit();
  }

  Future<void> fetchPromoCodes() async {
    try {
      isLoading.value = true;
      CommonLoader.show();

      final snapshot = await _firestore
          .collection(AppConstantStrings.promoCodeCollection)
          .orderBy('createdAt', descending: true)
          .get();

      promoCodes.value = snapshot.docs
          .map((doc) => PromoCodeModel.fromDoc(doc))
          .where(_isValidPromo)
          .toList();
    } finally {
      isLoading.value = false;
      CommonLoader.hide();
    }
  }

  bool _isValidPromo(PromoCodeModel promo) {
    final now = DateTime.now();

    if (now.isBefore(promo.startDate)) return false;
    if (now.isAfter(promo.endDate)) return false;

    return true;
  }

  String getDiscountTitle(PromoCodeModel promo) {
    if (promo.discountType == "percentage") {
      return "${promo.discountValue}% OFF";
    }
    return "${AppConstantStrings.rupeeSymbol} ${promo.discountValue} OFF";
  }

  String getDiscountBadge(PromoCodeModel promo) {
    if (promo.discountType == "percentage") {
      return "${promo.discountValue}%\nOFF";
    }
    return "${AppConstantStrings.rupeeSymbol} ${promo.discountValue}\nOFF";
  }

  String getDescription(PromoCodeModel promo) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return "On orders above ${formatter.format(promo.minOrderAmount)}";
  }

  // /// Validate before applying
  // String? validatePromo({
  //   required PromoCodeModel promo,
  //   required double cartTotal,
  // }) {
  //   if (cartTotal < promo.minOrderAmount) {
  //     return "Minimum order ₹${promo.minOrderAmount} required";
  //   }
  //   return null;
  // }
}
