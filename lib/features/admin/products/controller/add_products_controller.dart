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
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/admin/settings/view/manage_category.dart';
import 'package:online_groceries_app/features/admin/store_manage/models/store_model.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AdminProductController extends GetxController {
  /// TEXT CONTROLLERS
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final priceController = TextEditingController();

  RxList<StoreStockModel> storeStocks = <StoreStockModel>[].obs;

  final descriptionController = TextEditingController();
  final packagingController = TextEditingController();
  final TextEditingController kpsController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  /// DROPDOWNS
  final selectedCategory = ''.obs;
  final selectedCategoryId = ''.obs;
  final selectedUnit = ''.obs;

  /// PACKAGING
  final packagingList = <String>[].obs;

  /// IMAGE (WEB + MOBILE)
  final thumbnailFile = Rx<File?>(null);
  final thumbnailBytes = Rx<Uint8List?>(null);

  final productImages = <File>[].obs;
  final productImagesBytes = <Uint8List>[].obs;

  /// IMAGE URLS (EDIT MODE)
  final thumbnailUrl = ''.obs;
  final productImageUrls = <String>[].obs;

  /// EDIT MODE
  final isEdit = false.obs;
  String? productId;

  final isLoading = false.obs;

  final ImagePicker picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// CATEGORIES
  final categories = <CategoryModel>[].obs;
  final isCategoryLoading = true.obs;

  RxList<StoreModel> stores = <StoreModel>[].obs;
  RxList<StoreModel> selectedStores = <StoreModel>[].obs;
  Future<void> fetchStores() async {
    final snapshot =
    await FirebaseFirestore.instance.collection(AppConstantStrings.storesCollection).get();

    stores.value = snapshot.docs
        .map((doc) => StoreModel.fromJson(doc.id, doc.data()))
        .toList();
    if (isEdit.value && _editProductCache != null) {
      _prefillStoreStocks(_editProductCache!);
    }
  }

  void _prefillStoreStocks(ProductModel product) {
    selectedStores.clear();
    storeStocks.clear();

    for (final storeStock in product.storeStocks) {
      final store = stores.firstWhereOrNull(
            (s) => s.id == storeStock.storeId,
      );

      if (store != null) {
        selectedStores.add(store);

        storeStocks.add(
          StoreStockModel(
            storeId: store.id,
            storeName: store.name,
            stock: storeStock.stock,
          ),
        );
      }
    }
  }

  ProductModel? _editProductCache;


  @override
  void onInit() {
    super.onInit();
    productImages.clear();
    productImagesBytes.clear();
    fetchStores();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isCategoryLoading.value = true;

      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstantStrings.categoryCollection)
          .get();

      categories.value = snapshot.docs
          .map((doc) => CategoryModel.fromSnapshot(doc.id, doc.data()))
          .toList();
    } catch (e, s) {
      print(e);
      print(s);
      CommonToast.show("Failed to load categories", type: ToastType.error);
    } finally {
      isCategoryLoading.value = false;
    }
  }

  void setEditProduct(ProductModel product) {
    isEdit.value = true;
    productId = product.id;

    /// 🔥 cache product (IMPORTANT)
    _editProductCache = product;

    /// BASIC FIELDS
    nameController.text = product.name;
    brandController.text = product.brand;
    priceController.text = product.price.toString();
    descriptionController.text = product.description;
    kpsController.text = product.kps.toString();
    discountController.text = product.discount.toString();

    selectedCategory.value = product.categoryName;
    selectedCategoryId.value = product.categoryId;
    selectedUnit.value = product.priceUnit;

    packagingList.assignAll(product.packaging);

    thumbnailUrl.value = product.thumbnail;
    productImageUrls.assignAll(product.images);

    /// ✅ If stores already loaded → prefill now
    if (stores.isNotEmpty) {
      _prefillStoreStocks(product);
    }
  }

  Future<void> pickThumbnail() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (kIsWeb) {
      thumbnailBytes.value = await image.readAsBytes();
      thumbnailFile.value = null;
    } else {
      thumbnailFile.value = File(image.path);
      thumbnailBytes.value = null;
    }
  }

  void removeThumbnail() {
    thumbnailFile.value = null;
    thumbnailBytes.value = null;
    thumbnailUrl.value = '';
  }

  void removeProductImage({
    required bool isOld,
    required int index,
  }) {
    if (isOld) {
      final url = productImageUrls[index];
      productImageUrls.removeAt(index);
      deleteOldImage(url);
    } else {
      if (kIsWeb) {
        productImagesBytes.removeAt(index);
      } else {
        productImages.removeAt(index);
      }
    }
  }



  Future<void> pickProductImages() async {
    final images = await picker.pickMultiImage();
    if (images.isEmpty) return;

    final remaining =
        3 - (productImageUrls.length +
            (kIsWeb ? productImagesBytes.length : productImages.length));

    for (int i = 0; i < images.length && i < remaining; i++) {
      final img = images[i];

      if (kIsWeb) {
        final bytes = await img.readAsBytes();

        // ❌ duplicate bytes check
        if (!productImagesBytes.any((e) => e.length == bytes.length)) {
          productImagesBytes.add(bytes);
        }
      } else {
        final file = File(img.path);

        // ❌ duplicate file check
        if (!productImages.any((e) => e.path == file.path)) {
          productImages.add(file);
        }
      }
    }
  }

  Future<void> deleteOldImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint("Image delete failed: $e");
    }
  }
  Future<void> replaceProductImage(int index) async {
    final image =
    await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (kIsWeb) {
      productImagesBytes[index] = await image.readAsBytes();
    } else {
      productImages[index] = File(image.path);
    }
  }

  Future<String> _uploadImage({
    File? file,
    Uint8List? bytes,
    required String path,
  }) async {
    final ref = _storage.ref().child(path);

    if (kIsWeb && bytes != null) {
      await ref.putData(bytes);
    } else if (file != null) {
      await ref.putFile(file);
    } else {
      throw Exception("No image data");
    }

    return await ref.getDownloadURL();
  }

  Future<void> saveProduct() async {
    /// THUMBNAIL VALIDATION
    final hasThumbnail = isEdit.value
        ? thumbnailUrl.value.isNotEmpty ||
        thumbnailBytes.value != null ||
        thumbnailFile.value != null
        : (kIsWeb
        ? thumbnailBytes.value != null
        : thumbnailFile.value != null);

    if (!hasThumbnail) {
      CommonToast.show(
        "Please select thumbnail image",
        type: ToastType.warning,
      );
      return;
    }

    final name = nameController.text.trim();
    final brand = brandController.text.trim();
    final priceText = priceController.text.trim();
    final description = descriptionController.text.trim();
    final kpsText = kpsController.text.trim();
    final discountText = discountController.text.trim();

    /// NAME
    if (name.isEmpty) {
      CommonToast.show("Please enter product name", type: ToastType.warning);
      return;
    }

    /// BRAND
    if (brand.isEmpty) {
      CommonToast.show("Please enter brand name", type: ToastType.warning);
      return;
    }

    /// CATEGORY
    if (selectedCategory.value.isEmpty) {
      CommonToast.show("Please select a category", type: ToastType.warning);
      return;
    }

    /// UNIT
    if (selectedUnit.value.isEmpty) {
      CommonToast.show("Please select price unit", type: ToastType.warning);
      return;
    }

    /// PRICE
    if (priceText.isEmpty) {
      CommonToast.show("Please enter price", type: ToastType.warning);
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      CommonToast.show("Please enter a valid price", type: ToastType.warning);
      return;
    }

    if (storeStocks.isEmpty) {
      CommonToast.show(
        "Please select at least one store",
        type: ToastType.warning,
      );
      return;
    }

    for (final s in storeStocks) {
      if (s.stock <= 0) {
        CommonToast.show(
          "Enter valid stock for ${s.storeName}",
          type: ToastType.warning,
        );
        return;
      }
    }


    /// PACKAGING
    if (packagingList.isEmpty) {
      CommonToast.show("Please add at least one packaging option",
          type: ToastType.warning);
      return;
    }

    /// DESCRIPTION
    if (description.isEmpty) {
      CommonToast.show("Please enter product description",
          type: ToastType.warning);
      return;
    }

    /// KPS (OPTIONAL BUT IF FILLED → VALIDATE)
    if (kpsText.isNotEmpty) {
      final kps = int.tryParse(kpsText);
      if (kps == null || kps <= 0) {
        CommonToast.show("Please enter valid KPS value",
            type: ToastType.warning);
        return;
      }
    }

    /// DISCOUNT (OPTIONAL)
    if (discountText.isNotEmpty) {
      final discount = double.tryParse(discountText);
      if (discount == null || discount < 0 || discount > 100) {
        CommonToast.show("Discount must be between 0 and 100",
            type: ToastType.warning);
        return;
      }
    }

    CommonLoader.show();
    isLoading.value = true;

    try {
      final doc = _firestore
          .collection(AppConstantStrings.productsCollection)
          .doc(isEdit.value ? productId : null);

      /// THUMBNAIL UPLOAD (ONLY IF CHANGED)
      if (thumbnailBytes.value != null ||
          thumbnailFile.value != null) {
        thumbnailUrl.value = await _uploadImage(
          file: thumbnailFile.value,
          bytes: thumbnailBytes.value,
          path: "products/${doc.id}/thumbnail.jpg",
        );
      }

      /// PRODUCT IMAGES (ONLY IF NEW SELECTED)
      /// UPLOAD ONLY NEW IMAGES
      if ((kIsWeb && productImagesBytes.isNotEmpty) ||
          (!kIsWeb && productImages.isNotEmpty)) {
        final startIndex = productImageUrls.length;

        final count = kIsWeb
            ? productImagesBytes.length
            : productImages.length;

        for (int i = 0; i < count; i++) {
          final url = await _uploadImage(
            file: kIsWeb ? null : productImages[i],
            bytes: kIsWeb ? productImagesBytes[i] : null,
            path: "products/${doc.id}/images/img_${startIndex + i}.jpg",
          );
          productImageUrls.add(url);
        }

        productImages.clear();
        productImagesBytes.clear();
      }


      final product = ProductModel(
        id: doc.id,
        name: nameController.text.trim(),
        categoryName: selectedCategory.value,
        categoryId: selectedCategoryId.value,
        brand: brandController.text.trim(),
        priceUnit: selectedUnit.value,
        price: double.parse(priceController.text),
          storeStocks: storeStocks,
        description: descriptionController.text.trim(),
        thumbnail: thumbnailUrl.value,
        images: productImageUrls,
        packaging: packagingList,
        createdAt: DateTime.now(),
        discount: int.parse(discountText),
        kps: int.parse(kpsController.text.trim())
      );

      if (isEdit.value) {
        await doc.update(product.toJson());
      } else {
        await doc.set(product.toJson());
      }
      Get.back();
      clearForm();
      Get.back();
      Get.back();
      CommonToast.show(
        isEdit.value
            ? "Product updated successfully"
            : "Product added successfully",
        type: ToastType.success,
      );

    } catch (e) {
      CommonToast.show(e.toString(), type: ToastType.error);
    } finally {
      CommonLoader.hide();
      isLoading.value = false;
    }
  }


  void addPackaging() {
    final value = packagingController.text.trim();
    if (value.isNotEmpty && !packagingList.contains(value)) {
      packagingList.add(value);
      packagingController.clear();
    }
  }

  void clearForm() {
    nameController.clear();
    brandController.clear();
    priceController.clear();
    descriptionController.clear();
    packagingController.clear();
    packagingList.clear();
    kpsController.clear();
    discountController.clear();
    selectedStores.clear();

    selectedCategory.value = '';
    selectedCategoryId.value = '';
    selectedUnit.value = '';

    thumbnailFile.value = null;
    thumbnailBytes.value = null;
    thumbnailUrl.value = '';

    productImages.clear();
    productImagesBytes.clear();
    productImageUrls.clear();
    selectedStores.clear();

    isEdit.value = false;
    productId = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    brandController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    packagingController.dispose();
    super.onClose();
  }
}
