import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/models/feedback_model.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class FeedbackController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController feedbackController = TextEditingController();

  RxInt rating = 0.obs;

  void setRating(int value) {
    rating.value = value;
  }

  Future<void> submitFeedback() async {
    if (rating.value == 0) {
      CommonToast.show("Please rate your experience", type: ToastType.warning);
      return;
    }

    if (feedbackController.text.trim().isEmpty) {
      CommonToast.show("Please write your feedback", type: ToastType.warning);
      return;
    }

    final feedback = FeedbackModel(
      uid: UserService.getUserFromHive().uid,
      rating: rating.value,
      message: feedbackController.text.trim(),
      createdAt: Timestamp.now(),
    );
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      CommonLoader.show();

      await _firestore
          .collection(AppConstantStrings.feedbacksCollection)
          .add(feedback.toJson());

      CommonLoader.hide();
      Get.back(closeOverlays: true);
      CommonToast.show("Thank you for your feedback!", type: ToastType.success);
    } catch (e) {
      CommonLoader.hide();
      CommonToast.show("Failed to submit feedback", type: ToastType.error);
    }
  }

  @override
  void onClose() {
    feedbackController.dispose();
    super.onClose();
  }
}
