import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AdminBannerController extends GetxController {
  final ImagePicker picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// IMAGE
  final bannerFile = Rx<File?>(null);
  final bannerBytes = Rx<Uint8List?>(null);

  /// TEXT
  final titleController = TextEditingController();

  /// LIST
  RxList<BannerModel> banners = <BannerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  /// PICK IMAGE
  Future<void> pickBannerImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (kIsWeb) {
      bannerBytes.value = await image.readAsBytes();
      bannerFile.value = null;
    } else {
      bannerFile.value = File(image.path);
      bannerBytes.value = null;
    }
  }

  /// UPLOAD IMAGE
  Future<String> _uploadBanner(String id) async {
    final ref = _storage.ref().child("banners/$id.jpg");

    if (kIsWeb && bannerBytes.value != null) {
      await ref.putData(bannerBytes.value!);
    } else if (bannerFile.value != null) {
      await ref.putFile(bannerFile.value!);
    }

    return await ref.getDownloadURL();
  }

  /// ADD BANNER
  Future<void> addBanner() async {
    if (bannerFile.value == null && bannerBytes.value == null) {
      CommonToast.show("Please select banner image", type: ToastType.warning);
      return;
    }

    CommonLoader.show();

    final doc = _firestore.collection("banners").doc();

    final imageUrl = await _uploadBanner(doc.id);

    /// 🔥 next order = current banner count
    final order = banners.length;

    final banner = BannerModel(
      id: doc.id,
      title: titleController.text.trim(),
      image: imageUrl,
      order: order,
      createdAt: DateTime.now(),
    );

    await doc.set(banner.toJson());

    bannerFile.value = null;
    bannerBytes.value = null;
    titleController.clear();

    CommonLoader.hide();
    CommonToast.show("Banner added successfully", type: ToastType.success);

    fetchBanners();
  }

  Future<void> reorderBanner(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = banners.removeAt(oldIndex);
    banners.insert(newIndex, item);

    /// 🔥 Update order in Firestore
    for (int i = 0; i < banners.length; i++) {
      await _firestore
          .collection(AppConstantStrings.banners)
          .doc(banners[i].id)
          .update({"order": i});
    }

    CommonToast.show("Banner order updated",
        type: ToastType.success);
  }

  /// FETCH BANNERS
  Future<void> fetchBanners() async {
    final snapshot = await _firestore
        .collection(AppConstantStrings.banners)
        .orderBy("created_at", descending: true)
        .get();

    banners.value =
        snapshot.docs.map((e) => BannerModel.fromDoc(e)).toList();
  }

  /// DELETE BANNER
  Future<void> deleteBanner(BannerModel banner) async {
    await _storage.refFromURL(banner.image).delete();
    await _firestore.collection("banners").doc(banner.id).delete();
    banners.remove(banner);
    CommonToast.show("Banner delete successfully",type: ToastType.success);

  }
}
class BannerModel {
  final String id;
  final String title;
  final String image;
  final int order;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    required this.order,
    required this.createdAt,
  });

  factory BannerModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      order: data['order'] ?? 0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "image": image,
    "order": order,
    "created_at": Timestamp.fromDate(createdAt),
  };
}
