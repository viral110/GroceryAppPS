import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class FavouriteController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Observable favourite products
  final RxList<ProductModel> favouriteProducts = <ProductModel>[].obs;
  RxBool isLoading = false.obs;

  String? get _userId => UserService.getUserFromHive().uid;

  @override
  void onInit() {
    super.onInit();
    if (_userId != null) {
      loadFavourites();
    }
  }

  /// ================= LOAD FAVOURITES =================
  Future<void> loadFavourites() async {
    try {
      favouriteProducts.clear();

      final favSnap = await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(_userId)
          .collection(AppConstantStrings.favouritesCollection)
          .get();

      for (final doc in favSnap.docs) {
        final productId = doc.id;

        final productDoc = await _firestore
            .collection(AppConstantStrings.productsCollection)
            .doc(productId)
            .get();

        if (productDoc.exists) {
          favouriteProducts.add(ProductModel.fromDoc(productDoc));
        }
      }
    } catch (e) {
      CommonToast.show('Failed to load favourites', type: ToastType.error);
    }
  }

  /// ================= ADD =================
  Future<void> addToFavourites(ProductModel product) async {
    if (isFavourite(product.id)) return;

    try {
      await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(_userId)
          .collection(AppConstantStrings.favouritesCollection)
          .doc(product.id)
          .set({'product_id': product.id, 'added_at': Timestamp.now()});

      favouriteProducts.add(product);

      CommonToast.show(
        '${product.name} added to favourites',
        type: ToastType.success,
      );
    } catch (e) {
      CommonToast.show('Failed to add to favourites', type: ToastType.error);
    }
  }

  /// ================= REMOVE =================
  Future<void> removeFromFavourites(String productId) async {
    try {
      await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(_userId)
          .collection(AppConstantStrings.favouritesCollection)
          .doc(productId)
          .delete();

      favouriteProducts.removeWhere((p) => p.id == productId);

      CommonToast.show('Removed from favourites', type: ToastType.info);
    } catch (e) {
      CommonToast.show('Failed to remove favourite', type: ToastType.error);
    }
  }

  /// ================= TOGGLE =================
  void toggleFavourite(ProductModel product) {
    if (isFavourite(product.id)) {
      removeFromFavourites(product.id);
    } else {
      addToFavourites(product);
    }
  }

  /// ================= CHECK =================
  bool isFavourite(String productId) {
    return favouriteProducts.any((p) => p.id == productId);
  }

  /// ================= ADD ALL TO CART =================
  Future<void> addAllToCart() async {
    isLoading.value = true;
    if (favouriteProducts.isEmpty) {
      CommonToast.show(
        "You don't have any favourite products",
        type: ToastType.info,
      );
      return;
    }

    final cartController = Get.find<CartController>();
    final List<ProductModel> productsToMove = List<ProductModel>.from(
      favouriteProducts,
    );
    for (final product in productsToMove) {
      // 1️⃣ Add to cart
      await cartController.addToCart(product);

      // 2️⃣ Remove from favourites (Firestore + local)
      await _firestore
          .collection(AppConstantStrings.userCollection)
          .doc(_userId)
          .collection(AppConstantStrings.favouritesCollection)
          .doc(product.id)
          .delete();
    }

    // 3️⃣ Clear local list
    favouriteProducts.clear();
    isLoading.value = false;
    CommonToast.show(
      'All favourite items added to cart',
      type: ToastType.success,
    );
  }
}
