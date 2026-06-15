import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/admin/settings/controller/add_banner_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
import 'package:online_groceries_app/services/user_services.dart';
import '../../../admin/store_manage/models/store_model.dart';

class HomeController extends GetxController {
  // Pagination for exclusiveOffers
  final int pageSize = 5;
  final RxInt exclusivePage = 1.obs;

  List<ProductModel> get paginatedExclusiveOffers =>
      exclusiveOffers.take(exclusivePage.value * pageSize).toList();

  void loadMoreExclusive() {
    if (paginatedExclusiveOffers.length < exclusiveOffers.length) {
      exclusivePage.value += 1;
    }
  }

  final currentIndex = 0.obs;

  var banners = <BannerModel>[].obs;
  var isBannerLoading = false.obs;

  final homeSectionTitles = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
    fetchBanners();
    fetchHomeSectionTitles();
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

  Future<void> fetchHomeSectionTitles() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('home_sections')
        .get();

    for (final doc in snapshot.docs) {
      homeSectionTitles[doc['order']] = doc['title'];
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
        .collection(AppConstantStrings.storesCollection)
        .orderBy('createdAt', descending: true)
        .get();

    stores.assignAll(
      snapshot.docs.map((doc) => StoreModel.fromJson(doc.id, doc.data())),
    );

    // ✅ default selected store
    if (stores.isNotEmpty) {
      selectedStoreId.value = UserService.getUserFromHive().storeId.isNotEmpty
          ? UserService.getUserFromHive().storeId
          : "";
      log("✅ SELECTED STORE ID: ${selectedStoreId.value}");

      /// 👇 fetch products AFTER store selected
      await fetchProducts();
    }
  }

  /// PRODUCTS
  final allProducts = <ProductModel>[].obs;
  final exclusiveOffers = <ProductModel>[].obs;
  final bestSelling = <ProductModel>[].obs;
  final randomProducts = <ProductModel>[].obs;

  int maxDiscountForStore(ProductModel product, String storeId) {
    final store = product.storeConfigs.firstWhere(
      (s) => s.storeId == storeId,
      orElse: () => StoreProductConfig(
        storeId: '',
        storeName: '',
        unit: '',
        packaging: [],
      ),
    );

    int maxDiscount = 0;
    for (final p in store.packaging) {
      if (p.discount > maxDiscount) {
        maxDiscount = p.discount;
      }
    }
    return maxDiscount;
  }

  int totalStockForStore(ProductModel product, String storeId) {
    final store = product.storeConfigs.firstWhere(
      (s) => s.storeId == storeId,
      orElse: () => StoreProductConfig(
        storeId: '',
        storeName: '',
        unit: '',
        packaging: [],
      ),
    );

    int total = 0;
    for (final p in store.packaging) {
      total += p.quantity;
    }
    return total;
  }

  /// 🔥 PRODUCTS FETCH
  Future<void> fetchProducts() async {
    if (selectedStoreId.value.isEmpty) {
      log("❌ StoreId empty, skipping product fetch");
      return;
    }

    final storeId = selectedStoreId.value;

    final snapshot = await _firestore
        .collection(AppConstantStrings.productsCollection)
        .where('store_ids', arrayContains: storeId)
        .get();

    final products = snapshot.docs.map((e) => ProductModel.fromDoc(e)).toList();

    allProducts.assignAll(products);

    /// ⭐ EXCLUSIVE (20–30% discount)
    exclusiveOffers.assignAll(
      products.where((product) {
        final discount = maxDiscountForStore(product, storeId);
        return discount >= AppConstantStrings.minDiscount &&
            discount <= AppConstantStrings.maxDiscount;
      }).toList(),
    );

    /// 🔥 BEST SELLING (LOW STOCK FIRST)
    final bestSellingList =
        products.where((p) => totalStockForStore(p, storeId) > 0).toList()
          ..sort(
            (a, b) => totalStockForStore(
              a,
              storeId,
            ).compareTo(totalStockForStore(b, storeId)),
          );

    bestSelling.assignAll(bestSellingList);

    /// 🎲 RANDOM 10
    final shuffled = [...products]..shuffle();
    randomProducts.assignAll(shuffled.take(10).toList());
  }

  Future<void> onStoreChanged(String storeId) async {
    selectedStoreId.value = storeId;
    CommonLoader.show();
    final user = UserService.getUserFromHive();
    user.storeId = storeId;
    await UserService().updateUser(user);
    await clearUserCart(user.uid);
    await clearUserFavourites(user.uid);
    await fetchProducts(); // 🔥 reload products
    CommonLoader.hide();
  }

  Future<void> clearUserCart(String userId) async {
    final cartRef = FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(userId)
        .collection(AppConstantStrings.cartCollection);

    final snapshot = await cartRef.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> clearUserFavourites(String userId) async {
    final favRef = FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(userId)
        .collection(AppConstantStrings.favouritesCollection);

    final snapshot = await favRef.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// ✅ Get products for a specific section type
  List<ProductModel> getProductsForSection(String type) {
    switch (type) {
      case 'exclusive':
        return exclusiveOffers;
      case 'bestSelling':
        return bestSelling;
      case 'groceries':
        return randomProducts;
      default:
        return [];
    }
  }

  /// ✅ SINGLE SOURCE OF ADD TO CART
  Future<void> addProductToCart(ProductModel product, String storeId) async {
    final cartController = Get.put(CartController());

    /// 1️⃣ Get store config
    final StoreProductConfig? storeConfig = product.storeConfigs
        .firstWhereOrNull((s) => s.storeId == storeId);
    print("ADDPRODUCT");
    print(storeConfig?.packaging.toString());
    if (storeConfig == null) {
      CommonToast.show(
        "Product not available in this store",
        type: ToastType.warning,
      );
      return;
    }

    /// 2️⃣ Get default packaging
    final PackagingModel? packaging = storeConfig.packaging.firstWhereOrNull(
      (p) => p.isDefault,
    );

    if (packaging == null) {
      CommonToast.show(
        "Product packaging not available",
        type: ToastType.warning,
      );
      return;
    }

    /// 3️⃣ Selling price (already discounted)
    final double unitPrice = packaging.price;

    final int discount = packaging.discount;
    final double sellingPrice = discount > 0
        ? unitPrice - (unitPrice * discount / 100)
        : unitPrice;

    /// 5️⃣ Add to cart
    await cartController.addToCart(
      product: product,
      packaging: packaging,
      unitPrice: sellingPrice,
      quantity: 1,
    );
  }
}
