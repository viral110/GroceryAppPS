import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/settings/controller/add_banner_controller.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  var selectedLocation = "Manjalpur, Vadodara".obs;

  var banners = <BannerModel>[].obs;
  var isBannerLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  Future<void> fetchBanners() async {
    try {
      isBannerLoading.value = true;

      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstantStrings.banners)
          .orderBy('order')
          .get();

      banners.value = snapshot.docs.map((e) => BannerModel.fromDoc(e)).toList();
    } catch (e) {
      log("Banner fetch error: $e");
    } finally {
      isBannerLoading.value = false;
    }
  }

  // final List<String> banners = [
  //   "assets/png/banner.png", // same image can repeat
  //   "assets/png/banner.png",
  //   "assets/png/banner.png",
  // ];
  final List<Map<String, dynamic>> groceriesCategory = [
    {
      "image": "assets/png/pulses_image.png",
      "title": "Pulses",
      "color": Color(0xffF8A44C),
    },
    {
      "image": "assets/png/rice_image.png",
      "title": "Rice",
      "color": Color(0xff53B175),
    },
  ];
}
