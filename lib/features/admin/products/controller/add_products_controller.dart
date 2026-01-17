import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  RxList<StoreProductConfig> storeConfigs = <StoreProductConfig>[].obs;

  final descriptionController = TextEditingController();
  /// DROPDOWNS
  final selectedCategory = ''.obs;
  final selectedCategoryId = ''.obs;

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
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstantStrings.storesCollection)
        .get();

    stores.value = snapshot.docs
        .map((doc) => StoreModel.fromJson(doc.id, doc.data()))
        .toList();

    /// ✅ EDIT MODE → prefill from product
    if (isEdit.value && _editProductCache != null) {
      _prefillStoreStocks(_editProductCache!);
      return;
    }

    /// ✅ ADD MODE → auto select first store
    if (stores.isNotEmpty && storeConfigs.isEmpty) {
      final firstStore = stores.first;

      selectedStores.add(firstStore);

      storeConfigs.add(
        StoreProductConfig(
          storeId: firstStore.id,
          storeName: firstStore.name,
          unit: '',
          packaging: [],
        ),
      );
    }
  }


  void _prefillStoreStocks(ProductModel product) {
    selectedStores.clear();
    storeConfigs.clear();

    for (final storeStock in product.storeConfigs) {
      final store = stores.firstWhereOrNull(
            (s) => s.id == storeStock.storeId,
      );

      if (store != null) {
        selectedStores.add(store);

        storeConfigs.add(
          StoreProductConfig(
            storeId: store.id,
            storeName: store.name,
            unit: storeStock.unit, packaging:storeStock.packaging ,
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
    descriptionController.text = product.description;

    selectedCategory.value = product.categoryName;
    selectedCategoryId.value = product.categoryId;

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

    // ---------------- WEB ----------------
    if (kIsWeb) {
      final bytes = await image.readAsBytes();

      // ❌ Max 100 KB validation
      if (bytes.lengthInBytes > 200 * 1024) {
        CommonToast.show("Thumbnail must be under 100 KB");
        return;
      }

      thumbnailBytes.value = bytes;
      thumbnailFile.value = null;
    }

    // ---------------- MOBILE ----------------
    else {
      final file = File(image.path);
      final fileSize = await file.length();

      // ❌ Max 100 KB validation
      if (fileSize > 200 * 1024) {
        CommonToast.show("Thumbnail must be under 100 KB");
        return;
      }

      // 🔽 Compress thumbnail
      final compressedThumb = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.parent.path}/thumb_${file.uri.pathSegments.last}',
        quality: 55,
        minWidth: 300,
        minHeight: 300,
      );

      if (compressedThumb == null) return;

      thumbnailFile.value = File(compressedThumb.path);
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

      // ---------------- WEB ----------------
      if (kIsWeb) {
        final bytes = await img.readAsBytes();

        // ❌ Max 500 KB validation
        if (bytes.lengthInBytes > 800 * 1024) {
          CommonToast.show("Image must be under 500 KB");
          continue;
        }

        // ❌ Duplicate check
        if (!productImagesBytes.any((e) => e.length == bytes.length)) {
          productImagesBytes.add(bytes);
        }
      }

      // ---------------- MOBILE ----------------
      else {
        final file = File(img.path);

        // ❌ Max 500 KB validation
        final fileSize = await file.length();
        if (fileSize > 800 * 1024) {
          CommonToast.show("Image must be under 500 KB",type: ToastType.warning);
          continue;
        }

        // 🔽 Compress image
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          '${file.parent.path}/compressed_${file.uri.pathSegments.last}',
          quality: 75, // controls size (~250KB)
          minWidth: 1024,
          minHeight: 1024,
        );

        if (compressedFile == null) continue;

        // ❌ Duplicate check
        if (!productImages.any((e) => e.path == compressedFile.path)) {
          productImages.add(File(compressedFile.path));
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
    final description = descriptionController.text.trim();


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



    for (final store in storeConfigs) {
      if (store.unit.isEmpty) {
        CommonToast.show("Select unit for ${store.storeName}");
        return;
      }

      if (store.unit != "Packet" && store.packaging.isEmpty) {
        CommonToast.show("Add packaging for ${store.storeName}");
        return;
      }

      for (final pkg in store.packaging) {
        if (pkg.price <= 0) {
          CommonToast.show("Enter price for ${pkg.label}");
          return;
        }
        if (pkg.sku.isEmpty) {
          CommonToast.show("Enter SKU for ${pkg.label}");
          return;
        }
        if (pkg.discount < 0 || pkg.discount > 100) {
          CommonToast.show("Invalid discount for ${pkg.label}");
          return;
        }
      }

      final hasDefaultPackaging =
      store.packaging.any((pkg) => pkg.isDefault);

      if (!hasDefaultPackaging) {
        CommonToast.show(
          "Select one packaging to show for ${store.storeName}",
          type: ToastType.warning,
        );
        return;
      }
    }
    for (final s in storeConfigs) {
      if (s.packaging.isEmpty) {
        CommonToast.show(
          "Enter packaging",
          type: ToastType.warning,
        );
        return;
      }
    }




    /// DESCRIPTION
    if (description.isEmpty) {
      CommonToast.show("Please enter product description",
          type: ToastType.warning);
      return;
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

        description: descriptionController.text.trim(),
        thumbnail: thumbnailUrl.value,
        images: productImageUrls,
        createdAt: DateTime.now(),
       storeConfigs: storeConfigs,
        storeIds: storeConfigs.map((e) => e.storeId).toSet().toList(),
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


  void clearForm() {
    nameController.clear();
    brandController.clear();
    descriptionController.clear();
    selectedStores.clear();

    selectedCategory.value = '';
    selectedCategoryId.value = '';
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
    descriptionController.dispose();
    super.onClose();
  }

  void toggleStore(StoreModel store, bool selected) {
    if (selected) {
      storeConfigs.add(StoreProductConfig(
        storeId: store.id,
        storeName: store.name,
        unit: '',
        packaging: [],
      ));
    } else {
      storeConfigs.removeWhere((e) => e.storeId == store.id);
    }
  }
  void addPackaging(StoreProductConfig store, String value) {
    if (value.isEmpty) {
      CommonToast.show("Please Enter Packaging",type: ToastType.warning);
      return;
    }
    store.packaging.add(PackagingModel(
      label: value,
      price: 0,
      sku: '',
      discount: 0,
      quantity: 0,
    ));
    storeConfigs.refresh();
  }

  bool isValidPackagingForUnit({
    required String unit,
    required String value,
  }) {
    final v = value.toLowerCase().trim();

    switch (unit) {
      case "Kg":
      // 250g, 500g, 1kg
        return v.endsWith("g") || v.endsWith("kg");

      case "Gram":
      // only grams
        return v.endsWith("g");

      case "Liter":
      // 500ml, 1l
        return v.endsWith("ml") || v.endsWith("l");

      case "Ml":
      // only ml
        return v.endsWith("ml");

      case "Packet":
        return false;

      default:
        return false;
    }
  }

}
