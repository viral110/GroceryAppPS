import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AdminHomeSectionController extends GetxController {
  final title1 = TextEditingController();
  final title2 = TextEditingController();
  final title3 = TextEditingController();

  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSections();
  }

  Future<void> loadSections() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstantStrings.homeSectionsCollection)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      switch (data['order']) {
        case 1:
          title1.text = data['title'] ?? '';
          break;
        case 2:
          title2.text = data['title'] ?? '';
          break;
        case 3:
          title3.text = data['title'] ?? '';
          break;
      }
    }
  }

  Future<void> saveSections() async {
    isSaving.value = true;
    final ref = FirebaseFirestore.instance.collection(
      AppConstantStrings.homeSectionsCollection,
    );

    final batch = FirebaseFirestore.instance.batch();

    batch.set(ref.doc('section_1'), {
      'title': title1.text.trim(),
      'order': 1,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(ref.doc('section_2'), {
      'title': title2.text.trim(),
      'order': 2,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(ref.doc('section_3'), {
      'title': title3.text.trim(),
      'order': 3,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    isSaving.value = false;
    Get.back();
    CommonToast.show(
      "Home Section Title Updated Successfully....",
      type: ToastType.success,
    );
  }
}
