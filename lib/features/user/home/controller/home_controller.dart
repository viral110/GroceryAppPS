import 'dart:ui';

import 'package:get/get.dart';

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

}