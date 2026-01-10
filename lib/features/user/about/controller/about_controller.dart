import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/models/about_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AboutController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rxn<AboutModel> about = Rxn<AboutModel>();
  RxBool isLoading = true.obs;
  RxBool isNoData = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 🔑 Delay until UI build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAboutInfo();
    });
  }

  Future<void> fetchAboutInfo() async {
    try {
      isNoData.value = false;
      CommonLoader.show();

      final doc = await _firestore
          .collection(AppConstantStrings.appInfoCollection)
          .doc('about')
          .get();

      if (doc.exists && doc.data() != null) {
        about.value = AboutModel.fromMap(doc.data()!);
      } else {
        isNoData.value = true;
      }
    } catch (e) {
      isNoData.value = true;
      CommonToast.show("Failed to load app information", type: ToastType.error);
    } finally {
      CommonLoader.hide();
    }
  }
}
