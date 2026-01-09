import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/settings/view/manage_category.dart';
import 'package:online_groceries_app/models/category_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class CategoryController extends GetxController {
  final TextEditingController nameController = TextEditingController();

  final isLoading = false.obs;
  final isEdit = false.obs;

  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  final RxString imageName = "".obs;
  final RxString oldImageUrl = "".obs;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String editingDocId = "";

  final ImagePicker _picker = ImagePicker();

  CollectionReference get _ref => FirebaseFirestore.instance.collection(
    AppConstantStrings.categoryCollection,
  );

  /// PICK IMAGE
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imageBytes.value = await image.readAsBytes();
      imageName.value = image.name;
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

  /// UPLOAD IMAGE
  // Future<String> _uploadImage() async {
  //   if (imageBytes.value == null) {
  //     throw Exception("No image selected");
  //   }
  //
  //   final fileName =
  //       "category_${DateTime.now().millisecondsSinceEpoch}_${imageName.value}";
  //
  //   final ref = FirebaseStorage.instance
  //       .ref('categories/$fileName');
  //
  //   await ref.putData(
  //     imageBytes.value!,
  //     SettableMetadata(
  //       contentType: fileName.endsWith('.png')
  //           ? 'image/png'
  //           : 'image/jpeg',
  //     ),
  //   );
  //
  //   return await ref.getDownloadURL();
  // }

  /// ADD CATEGORY
  Future<void> addCategory() async {
    if (nameController.text.trim().isEmpty) {
      CommonToast.show("Enter category name", type: ToastType.warning);
      return;
    }

    if (imageBytes.value == null) {
      CommonToast.show("Please select category image", type: ToastType.warning);
      return;
    }

    try {
      isLoading(true);

      final imageUrl = await _uploadImage(
        bytes: imageBytes.value,
        path:
            'categories/category_${DateTime.now().millisecondsSinceEpoch}_${imageName.value}',
      );

      await _ref.add({
        "name": nameController.text.trim(),
        "image_url": imageUrl,
        "created_at": FieldValue.serverTimestamp(),
      });

      resetForm();

      CommonToast.show("Category added successfully", type: ToastType.success);
    } catch (e) {
      CommonToast.show(e.toString(), type: ToastType.error);
    } finally {
      isLoading(false);
    }
  }

  /// UPDATE CATEGORY
  Future<void> updateCategory() async {
    if (nameController.text.trim().isEmpty) {
      CommonToast.show("Enter category name", type: ToastType.warning);
      return;
    }

    try {
      isLoading(true);
      String imageUrl = oldImageUrl.value;

      if (imageBytes.value != null) {
        // delete old image
        if (oldImageUrl.value.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(oldImageUrl.value).delete();
        }

        imageUrl = await _uploadImage(bytes: imageBytes.value, path: '');
      }

      await _ref.doc(editingDocId).update({
        "name": nameController.text.trim(),
        "image_url": imageUrl,
      });

      resetForm();
      Get.back();

      CommonToast.show("Category updated", type: ToastType.success);
    } catch (e) {
      CommonToast.show(e.toString(), type: ToastType.error);
    } finally {
      isLoading(false);
    }
  }

  /// DELETE CATEGORY
  Future<void> deleteCategory(String id, String imageUrl) async {
    try {
      await _ref.doc(id).delete();

      if (imageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }

      CommonToast.show("Category deleted", type: ToastType.success);
    } catch (e) {
      CommonToast.show(e.toString(), type: ToastType.error);
    }
  }

  /// OPEN EDIT MODE
  void openEditCategory(CategoryModel category) {
    isEdit.value = true;
    editingDocId = category.id;

    nameController.text = category.name;
    oldImageUrl.value = category.imageUrl;
    imageBytes.value = null;
  }

  /// RESET FORM
  void resetForm() {
    nameController.clear();
    imageBytes.value = null;
    imageName.value = "";
    oldImageUrl.value = "";
    isEdit.value = false;
    editingDocId = "";
  }

  /// STREAM

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
