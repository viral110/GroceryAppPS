import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/store_manage/models/store_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class StoreController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<StoreModel> stores = <StoreModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  /// Fetch Stores
  void fetchStores() {
    _firestore.collection(AppConstantStrings.storesCollection).orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      stores.value = snapshot.docs
          .map((doc) => StoreModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  /// Add Store
  Future<void> addStore({
    required String name,
    required String address,
  }) async {
    isLoading.value = true;
    await _firestore.collection('stores').add({
      'name': name,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
    });
    isLoading.value = false;
  }

  /// Update Store
  Future<void> updateStore({
    required String id,
    required String name,
    required String address,
  }) async {
    await _firestore.collection('stores').doc(id).update({
      'name': name,
      'address': address,
    });
  }

  /// Delete Store
  Future<void> deleteStore(String id) async {
    await _firestore.collection('stores').doc(id).delete();
  }
}
