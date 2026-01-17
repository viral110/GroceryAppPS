import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class StoreProductController extends GetxController {
  final String storeId;
  StoreProductController(this.storeId);

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;

  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchStoreProducts();
  }

  Future<void> fetchStoreProducts() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection(AppConstantStrings.productsCollection)
          .where('store_ids', arrayContains: storeId)
          .get();

      products.assignAll(
        snapshot.docs.map((e) => ProductModel.fromDoc(e)).toList(),
      );
    } catch (e) {
      CommonToast.show("Failed to load products", type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 Get store config for this store
  StoreProductConfig? getStoreConfig(ProductModel product) {
    return product.storeConfigs.firstWhereOrNull(
          (e) => e.storeId == storeId,
    );
  }

  /// 🔥 Update quantity for a packaging
  Future<void> updatePackagingQuantity({
    required String productId,
    required String storeId,
    required String packagingLabel,
    required int newQty,
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstantStrings.productsCollection)
          .doc(productId);

      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;

      final List storeConfigs = data['store_configs'];

      for (final store in storeConfigs) {
        if (store['store_id'] == storeId) {
          for (final pkg in store['packaging']) {
            if (pkg['label'] == packagingLabel) {
              pkg['quantity'] = newQty;
            }
          }
        }
      }

      await docRef.update({
        'store_configs': storeConfigs,
      });

      /// 🔁 LOCAL UPDATE
      final pIndex = products.indexWhere((p) => p.id == productId);
      final storeConfig = products[pIndex]
          .storeConfigs
          .firstWhere((s) => s.storeId == storeId);

      final pkg = storeConfig.packaging
          .firstWhere((p) => p.label == packagingLabel);

      pkg.quantity = newQty;

      products.refresh();
      Get.back();
      CommonToast.show("Quantity updated");
    } catch (e) {
      CommonToast.show("Failed to update quantity",
          type: ToastType.error);
    }
  }
  Future<void> setDefaultPackaging({
    required String productId,
    required String storeId,
    required String selectedLabel,
  }) async {
    final index =
    products.indexWhere((p) => p.id == productId);

    if (index == -1) return;

    final product = products[index];
    final storeConfig =
    getStoreConfig(product);

    if (storeConfig == null) return;

    // ✅ sirf ek default
    for (final pkg in storeConfig.packaging) {
      pkg.isDefault = pkg.label == selectedLabel;
    }

    await _firestore
        .collection(AppConstantStrings.productsCollection)
        .doc(productId)
        .update({
      "storeConfigs": product.storeConfigs.map((e) => e.toJson()).toList(),
    });

    update(); // GetBuilder refresh
  }

}
