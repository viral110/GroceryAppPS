import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/services/user_services.dart';

import '../../../admin/store_manage/models/store_model.dart';

class HomeController extends GetxController{
  final currentIndex = 0.obs;
  var selectedLocation = "Manjalpur, Vadodara".obs;
  void onPageChanged(int index) {
    currentIndex.value = index;
  }
  final List<String> banners = [
    "assets/png/banner.png", // same image can repeat
    "assets/png/banner.png",
    "assets/png/banner.png",
  ];
  final List<Map<String, dynamic>> groceriesCategory = [
    {
      "image": "assets/png/pulses_image.png",
      "title": "Pulses",
      "color":Color(0xffF8A44C)
    },
    {
      "image": "assets/png/rice_image.png",
      "title": "Rice",
      "color":Color(0xff53B175)
    },
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final stores = <StoreModel>[].obs;
  final selectedStoreId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  Future<void> fetchStores() async {
    final snapshot = await _firestore
        .collection('stores')
        .orderBy('createdAt', descending: true)
        .get();

    stores.assignAll(
      snapshot.docs.map(
            (doc) => StoreModel.fromJson(doc.id, doc.data()),
      ),
    );

    // ✅ default selected store
    if (stores.isNotEmpty) {
      selectedStoreId.value = UserService.getUserFromHive().storeId.isNotEmpty ?UserService.getUserFromHive().storeId :"";
    }
  }

}