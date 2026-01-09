// import 'dart:io';
// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:online_groceries_app/common_widgets/common_tost.dart';
// import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
// import 'package:online_groceries_app/features/admin/settings/view/manage_category.dart';
//
// class AdminProductController extends GetxController {
//   /// TEXT CONTROLLERS
//   final nameController = TextEditingController();
//   final brandController = TextEditingController();
//   final priceController = TextEditingController();
//   final stockController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final packagingController = TextEditingController();
//
//   /// DROPDOWNS
//   final selectedCategory = ''.obs;
//   final selectedCategoryId = ''.obs;
//   final selectedUnit = ''.obs;
//
//   /// PACKAGING
//   final packagingList = <String>[].obs;
//
//   /// IMAGES (MOBILE + WEB)
//   final thumbnailFile = Rx<File?>(null);
//   final thumbnailBytes = Rx<Uint8List?>(null);
//
//   final productImages = <File>[].obs;
//   final productImagesBytes = <Uint8List>[].obs;
//
//   /// IMAGE URLS
//   final thumbnailUrl = ''.obs;
//   final productImageUrls = <String>[].obs;
//
//   final isLoading = false.obs;
//
//   final ImagePicker picker = ImagePicker();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   /// CATEGORIES
//   final categories = <CategoryModel>[].obs;
//   final isCategoryLoading = true.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchCategories();
//   }
//
//   Future<void> fetchCategories() async {
//     try {
//       isCategoryLoading.value = true;
//
//       final snapshot =
//       await FirebaseFirestore.instance.collection('categories').get();
//
//       categories.value = snapshot.docs
//           .map((doc) =>
//           CategoryModel.fromDoc(doc.data(), doc.id))
//           .toList();
//     } catch (e) {
//       CommonToast.show(
//         "Failed to load categories",
//         type: ToastType.error,
//       );
//     } finally {
//       isCategoryLoading.value = false;
//     }
//   }
//
//
//
//   /// REMOVE THUMBNAIL
//   void removeThumbnail() {
//     thumbnailFile.value = null;
//     thumbnailBytes.value = null;
//   }
//
//   /// REPLACE / PICK THUMBNAIL
//   Future<void> pickThumbnail() async {
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//
//     if (kIsWeb) {
//       thumbnailBytes.value = await image.readAsBytes();
//       thumbnailFile.value = null;
//     } else {
//       thumbnailFile.value = File(image.path);
//       thumbnailBytes.value = null;
//     }
//   }
//
//
//   /// PICK MULTIPLE PRODUCT IMAGES
//   Future<void> pickProductImages() async {
//     final List<XFile> images = await picker.pickMultiImage();
//     for (final img in images) {
//       if (kIsWeb) {
//         productImagesBytes.add(await img.readAsBytes());
//       } else {
//         productImages.add(File(img.path));
//       }
//     }
//   }
//
//   /// UPLOAD IMAGE (WEB + MOBILE)
//   Future<String> _uploadImage({
//     File? file,
//     Uint8List? bytes,
//     required String path,
//   }) async {
//     final ref = _storage.ref().child(path);
//
//     if (kIsWeb && bytes != null) {
//       await ref.putData(bytes);
//     } else if (file != null) {
//       await ref.putFile(file);
//     } else {
//       throw Exception("No image data found");
//     }
//
//     return await ref.getDownloadURL();
//   }
//
//   /// SAVE PRODUCT
//   Future<void> saveProduct() async {
//     /// THUMBNAIL VALIDATION
//     if ((kIsWeb && thumbnailBytes.value == null) ||
//         (!kIsWeb && thumbnailFile.value == null)) {
//       CommonToast.show(
//         "Please select category image",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// PRODUCT IMAGES VALIDATION
//     final imageCount =
//     kIsWeb ? productImagesBytes.length : productImages.length;
//
//     if (imageCount == 0) {
//       CommonToast.show(
//         "Please add at least one product image",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// PRODUCT NAME
//     if (nameController.text.trim().isEmpty) {
//       CommonToast.show(
//         "Please enter product name",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// CATEGORY
//     if (selectedCategory.value.isEmpty) {
//       CommonToast.show(
//         "Please select category",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// BRAND
//     if (brandController.text.trim().isEmpty) {
//       CommonToast.show(
//         "Please enter brand name",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// PRICE UNIT
//     if (selectedUnit.value.isEmpty) {
//       CommonToast.show(
//         "Please select price unit",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// PRICE
//     if (priceController.text.trim().isEmpty) {
//       CommonToast.show(
//         "Please enter product price",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     if (packagingList.isEmpty) {
//       CommonToast.show(
//         "Please add at least one packaging option",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// STOCK
//     if (stockController.text.trim().isEmpty) {
//       CommonToast.show(
//         "Please enter product stock",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// DESCRIPTION
//     if (descriptionController.text.trim().isEmpty) {
//       CommonToast.show(
//         "Please enter product description",
//         type: ToastType.warning,
//       );
//       return;
//     }
//
//     /// START LOADING
//     isLoading.value = true;
//
//     try {
//       final doc = _firestore.collection("products").doc();
//
//       /// UPLOAD THUMBNAIL
//       thumbnailUrl.value = await _uploadImage(
//         file: thumbnailFile.value,
//         bytes: thumbnailBytes.value,
//         path: "products/${doc.id}/thumbnail.jpg",
//       );
//
//       /// UPLOAD PRODUCT IMAGES
//       productImageUrls.clear();
//
//       for (int i = 0; i < imageCount; i++) {
//         final url = await _uploadImage(
//           file: kIsWeb ? null : productImages[i],
//           bytes: kIsWeb ? productImagesBytes[i] : null,
//           path: "products/${doc.id}/images/img_$i.jpg",
//         );
//         productImageUrls.add(url);
//       }
//
//       final product = ProductModel(
//         id: doc.id,
//         name: nameController.text.trim(),
//         categoryName: selectedCategory.value,
//         categoryId: selectedCategoryId.value,
//         brand: brandController.text.trim(),
//         priceUnit: selectedUnit.value,
//         price: double.parse(priceController.text),
//         stock: int.parse(stockController.text),
//         description: descriptionController.text.trim(),
//         thumbnail: thumbnailUrl.value,
//         images: productImageUrls,
//         packaging: packagingList,
//         createdAt: DateTime.now(),
//       );
//
//       await doc.set(product.toJson());
//
//       CommonToast.show(
//         "Product added successfully",
//         type: ToastType.success,
//       );
//
//       clearForm();
//       Get.back();
//     } catch (e) {
//       CommonToast.show(
//         e.toString(),
//         type: ToastType.error,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// ADD PACKAGING
//   void addPackaging() {
//     final value = packagingController.text.trim();
//     if (value.isNotEmpty && !packagingList.contains(value)) {
//       packagingList.add(value);
//       packagingController.clear();
//     }
//   }
//
//   /// REMOVE PRODUCT IMAGE
//   void removeProductImage(int index) {
//     if (kIsWeb) {
//       productImagesBytes.removeAt(index);
//     } else {
//       productImages.removeAt(index);
//     }
//   }
//
//   /// REPLACE PRODUCT IMAGE
//   Future<void> replaceProductImage(int index) async {
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//
//     if (kIsWeb) {
//       productImagesBytes[index] = await image.readAsBytes();
//     } else {
//       productImages[index] = File(image.path);
//     }
//   }
//
//
//   /// CLEAR FORM
//   void clearForm() {
//     nameController.clear();
//     brandController.clear();
//     priceController.clear();
//     stockController.clear();
//     descriptionController.clear();
//     packagingController.clear();
//     packagingList.clear();
//     selectedCategory.value = '';
//     selectedUnit.value = '';
//     thumbnailFile.value = null;
//     thumbnailBytes.value = null;
//     productImages.clear();
//     productImagesBytes.clear();
//   }
//
//   @override
//   void onClose() {
//     nameController.dispose();
//     brandController.dispose();
//     priceController.dispose();
//     stockController.dispose();
//     descriptionController.dispose();
//     packagingController.dispose();
//     super.onClose();
//   }
// }
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';
import 'package:online_groceries_app/features/admin/settings/view/manage_category.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AdminProductController extends GetxController {
  /// TEXT CONTROLLERS
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final packagingController = TextEditingController();

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

  @override
  void onInit() {
    super.onInit();
    productImages.clear();
    productImagesBytes.clear();
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

    nameController.text = product.name;
    brandController.text = product.brand;
    priceController.text = product.price.toString();
    stockController.text = product.stock.toString();
    descriptionController.text = product.description;

    selectedCategory.value = product.categoryName;
    selectedCategoryId.value = product.categoryId;
    selectedUnit.value = product.priceUnit;

    packagingList.assignAll(product.packaging);

    thumbnailUrl.value = product.thumbnail;
    productImageUrls.assignAll(product.images);
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

  void removeProductImage({required bool isOld, required int index}) {
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
        3 -
        (productImageUrls.length +
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
    final image = await picker.pickImage(source: ImageSource.gallery);
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
        : (kIsWeb ? thumbnailBytes.value != null : thumbnailFile.value != null);

    if (!hasThumbnail) {
      CommonToast.show(
        "Please select thumbnail image",
        type: ToastType.warning,
      );
      return;
    }

    if (nameController.text.trim().isEmpty ||
        brandController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        stockController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        selectedCategory.value.isEmpty ||
        selectedUnit.value.isEmpty ||
        packagingList.isEmpty) {
      CommonToast.show(
        "Please fill all required fields",
        type: ToastType.warning,
      );
      return;
    }

    isLoading.value = true;

    try {
      final doc = _firestore
          .collection("products")
          .doc(isEdit.value ? productId : null);

      /// THUMBNAIL UPLOAD (ONLY IF CHANGED)
      if (thumbnailBytes.value != null || thumbnailFile.value != null) {
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

        final count = kIsWeb ? productImagesBytes.length : productImages.length;

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
        stock: int.parse(stockController.text),
        description: descriptionController.text.trim(),
        thumbnail: thumbnailUrl.value,
        images: productImageUrls,
        packaging: packagingList,
        createdAt: DateTime.now(),
      );

      if (isEdit.value) {
        await doc.update(product.toJson());
      } else {
        await doc.set(product.toJson());
      }

      CommonToast.show(
        isEdit.value
            ? "Product updated successfully"
            : "Product added successfully",
        type: ToastType.success,
      );

      clearForm();
      Get.back();
    } catch (e) {
      CommonToast.show(e.toString(), type: ToastType.error);
    } finally {
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
    stockController.clear();
    descriptionController.clear();
    packagingController.clear();
    packagingList.clear();

    selectedCategory.value = '';
    selectedCategoryId.value = '';
    selectedUnit.value = '';

    thumbnailFile.value = null;
    thumbnailBytes.value = null;
    thumbnailUrl.value = '';

    productImages.clear();
    productImagesBytes.clear();
    productImageUrls.clear();

    isEdit.value = false;
    productId = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    brandController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    packagingController.dispose();
    super.onClose();
  }
}
