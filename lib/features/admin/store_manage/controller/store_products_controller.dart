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

      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstantStrings.productsCollection)
          .where('store_ids', arrayContains: storeId)
          .get();

      products.assignAll(
        snapshot.docs.map((e) => ProductModel.fromDoc(e)).toList(),
      );
    } catch (e) {
      CommonToast.show(
        "Failed to load products",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
  int getStock(ProductModel product, String storeId) {
    final stock = product.storeStocks.firstWhere(
          (e) => e.storeId == storeId,
      orElse: () => StoreStockModel(
        storeId: storeId,
        storeName: '',
        stock: 0,
      ),
    );
    return stock.stock;
  }
  Future<void> updateStoreStock({
    required String productId,
    required String storeId,
    required int newStock,
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstantStrings.productsCollection)
          .doc(productId);

      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;

      final List stocks = data['store_stock'];

      for (final s in stocks) {
        if (s['store_id'] == storeId) {
          s['stock'] = newStock;
        }
      }

      await docRef.update({
        'store_stock': stocks,
      });

      // 🔁 Update local state
      final index = products.indexWhere((p) => p.id == productId);
      products[index].storeStocks
          .firstWhere((e) => e.storeId == storeId)
          .stock = newStock;

      products.refresh();

      CommonToast.show("Stock updated");
    } catch (e) {
      CommonToast.show("Failed to update stock", type: ToastType.error);
    }
  }


}
