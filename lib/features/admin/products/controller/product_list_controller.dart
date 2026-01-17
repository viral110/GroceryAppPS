import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class ProductListController extends GetxController {
  final products = <ProductModel>[].obs;
  final isLoading = true.obs;

  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  /// ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection(AppConstantStrings.productsCollection)
          .get();
      products.value = snapshot.docs
          .map((doc) => ProductModel.fromDoc(doc))
          .toList();
    } catch (e,s) {
      print(e);
      print(s);
      CommonToast.show(
        "Failed to load products",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    try {
      isLoading.value = true;

      // delete thumbnail
      if (product.thumbnail.isNotEmpty) {
        await FirebaseStorage.instance
            .refFromURL(product.thumbnail)
            .delete();
      }

      // delete product images
      for (final url in product.images) {
        if (url.isNotEmpty) {
          await FirebaseStorage.instance
              .refFromURL(url)
              .delete();
        }
      }

      // delete firestore document
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .delete();

      products.removeWhere((p) => p.id == product.id);

      CommonToast.show(
        "Product deleted successfully",
        type: ToastType.success,
      );
    } catch (e) {
      CommonToast.show(
        "Failed to delete product",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

}
