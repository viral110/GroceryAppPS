import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class ProductListController extends GetxController {
  final _allProducts = <ProductModel>[].obs;
  final products = <ProductModel>[].obs;
  final isLoading = true.obs;
  RxString searchQuery = ''.obs; // 🔥 ADD THIS

  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    ever(searchQuery, (_) => _filterProducts());
  }

  /// ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection(AppConstantStrings.productsCollection)
          .get();

      _allProducts.value = snapshot.docs
          .map((doc) => ProductModel.fromDoc(doc))
          .toList();

      _allProducts.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      _filterProducts();
    } catch (e, s) {
      print(e);
      print(s);
      CommonToast.show("Failed to load products", type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    try {
      isLoading.value = true;

      // delete thumbnail
      if (product.thumbnail.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(product.thumbnail).delete();
      }

      // delete product images
      for (final url in product.images) {
        if (url.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(url).delete();
        }
      }

      // delete firestore document
      await FirebaseFirestore.instance
          .collection(AppConstantStrings.productsCollection)
          .doc(product.id)
          .delete();
      _allProducts.removeWhere((element) => element.id == product.id);
      products.removeWhere((p) => p.id == product.id);

      CommonToast.show("Product deleted successfully", type: ToastType.success);
    } catch (e) {
      CommonToast.show("Failed to delete product", type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) {
    searchQuery.value = value.toLowerCase().trim();
  }

  void _filterProducts() {
    List<ProductModel> filtered;

    if (searchQuery.value.isEmpty) {
      filtered = List.from(_allProducts);
    } else {
      filtered = _allProducts.where((product) {
        final name = product.name.toLowerCase();
        final category = product.categoryName.toLowerCase();
        final query = searchQuery.value.toLowerCase();

        return name.contains(query) || category.contains(query);
      }).toList();
    }

    // ✅ Alphabetical sorting
    filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    products.value = filtered;
  }}
