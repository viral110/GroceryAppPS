import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/models/support_model.dart';

class CustomerSupportController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  Rxn<SupportModel> support = Rxn<SupportModel>();
  RxBool isNoData = false.obs;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSupportInfo();
    });
  }

  Future<void> fetchSupportInfo() async {
    try {
      isNoData.value = false;
      CommonLoader.show();

      final doc = await _firestore.collection('app_info').doc('support').get();

      if (doc.exists && doc.data() != null) {
        support.value = SupportModel.fromMap(doc.data()!);
        log("SUPPORT: ${support.value}");
      } else {
        isNoData.value = true;
      }
    } catch (e) {
      isNoData.value = true;
      CommonToast.show("Unable to load support details", type: ToastType.error);
    } finally {
      CommonLoader.hide();
    }
  }
}
