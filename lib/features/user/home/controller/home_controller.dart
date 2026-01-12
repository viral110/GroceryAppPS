import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/admin/settings/controller/add_banner_controller.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
import 'package:online_groceries_app/services/user_services.dart';
import '../../../admin/store_manage/models/store_model.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  var banners = <BannerModel>[].obs;
  var isBannerLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final stores = <StoreModel>[].obs;
  final selectedStoreId = ''.obs;



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



  /// PRODUCTS
  final allProducts = <ProductModel>[].obs;
  final exclusiveOffers = <ProductModel>[].obs;
  final bestSelling = <ProductModel>[].obs;
  final randomProducts = <ProductModel>[].obs;

  /// 🔥 PRODUCTS FETCH
  Future<void> fetchProducts() async {
    if (selectedStoreId.value.isEmpty) {
      log("❌ StoreId empty, skipping product fetch");
      return;
    }

    log("🔥 Fetching products for store: ${selectedStoreId.value}");

    final snapshot = await _firestore
        .collection(AppConstantStrings.productsCollection)
        .where('store_ids', arrayContains: selectedStoreId.value)
        .get();

    final products = snapshot.docs.map((e) => ProductModel.fromDoc(e)).toList();

    log("🟢 PRODUCTS FOUND: ${products.length}");
    allProducts.assignAll(products);

    /// ⭐ Exclusive (20–30%)
    exclusiveOffers.assignAll(
      products
          .where(
            (p) =>
                p.discount >= AppConstantStrings.minDiscount &&
                p.discount <= AppConstantStrings.minDiscount,
          )
          .toList(),
    );
    log("EXCLUSIVE PRODUCTS:${exclusiveOffers.length}");

    /// 🔥 Best Selling (based on kps or flag)
    bestSelling.assignAll(products..sort((a, b) => b.kps.compareTo(a.kps)));

    // /// 🎲 Random 10 Products
    products.shuffle();
    randomProducts.assignAll(products.take(10).toList());
  }

  Future<void> onStoreChanged(String storeId) async {
    selectedStoreId.value = storeId;

    final user = UserService.getUserFromHive();
    user.storeId = storeId;
    UserService().updateUser(user);

    await fetchProducts(); // 🔥 reload products
  }
}
