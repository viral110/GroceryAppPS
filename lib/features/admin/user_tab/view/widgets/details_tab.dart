import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/change_password/view/change_password_view.dart';
import 'package:online_groceries_app/models/user_model.dart';
import 'package:online_groceries_app/services/admin_notification_service.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class UserDetailsTab extends StatelessWidget {
  final UserModel userModel;
  const UserDetailsTab(this.userModel);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          /// USER HEADER
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withAlpha(
                    (0.15 * 255).round(),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${userModel.firstName} ${userModel.lastName}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userModel.email ?? "",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                SizedBox(
                  width: 220.w,
                  child: CommonButton(
                    fontSize: 17.sp,

                    title: "Update User Credit",
                    onTap: () {
                      showUpdateCreditDialog(context, userModel);
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                SizedBox(
                  width: 200.w,
                  child: CommonButton(
                    fontSize: 16.sp,
                    title: "Reset Credit",
                    backgroundColor: Colors.redAccent,
                    onTap: () {
                      _showResetCreditConfirm(context, userModel.uid);
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          /// CREDIT SUMMARY
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(AppConstantStrings.userCollection)
                .doc(userModel.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final data = snapshot.data!.data() ?? {};

              final double totalCredit = (data['credit'] ?? 0).toDouble();
              final double spentCredit = (data['used_credits'] ?? 0).toDouble();
              final double pendingCredit = (data['remaining_credits'] ?? 0)
                  .toDouble();

              return Row(
                children: [
                  _creditCard(
                    "Current",
                    "₹${totalCredit.toStringAsFixed(2)}",
                    Colors.green,
                  ),
                  SizedBox(width: 12.w),
                  _creditCard(
                    "Spent",
                    "₹${spentCredit.toStringAsFixed(2)}",
                    Colors.orange,
                  ),
                  SizedBox(width: 12.w),
                  _creditCard(
                    "Pending",
                    "₹${pendingCredit.toStringAsFixed(2)}",
                    Colors.red,
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 24.h),

          _infoCard(
            title: "User Information",
            children: [
              _infoRow(
                leftLabel: "Name",
                leftValue: "${userModel.firstName} ${userModel.lastName}",

                rightLabel: "Email",
                rightValue: userModel.email ?? "",
              ),

              SizedBox(height: 30.h),

              _infoRow(
                leftLabel: "Mobile",
                leftValue: userModel.mobileNumber ?? "",
                rightLabel: "City",
                rightValue: userModel.city ?? "",
              ),

              SizedBox(height: 30.h),

              _infoRow(
                leftLabel: "State",
                leftValue: userModel.state ?? "",
                rightLabel: "Pincode",
                rightValue: userModel.pincode ?? "",
              ),
              SizedBox(height: 30.h),
              _infoRow(
                leftLabel: "Area",
                leftValue: userModel.area ?? "",
                rightLabel: "Business Name",
                rightValue: userModel.businessName ?? "",
              ),
            ],
          ),
          SizedBox(height: 30.h),
          CommonButton(
            onTap: () => Get.to(
              () => ChangePasswordView(
                email: userModel.email ?? "",
                userId: userModel.uid,
              ),
            ),
            title: 'Change Password',
          ),
        ],
      ),
    );
  }

  void showUpdateCreditDialog(BuildContext context, UserModel user) {
    final TextEditingController creditController = TextEditingController();
    final RxBool isAdd = true.obs;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420, // keep fixed for WEB
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(22.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  "Update Credit",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  "Add or deduct user credit balance",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.grayTextColor,
                  ),
                ),

                SizedBox(height: 22.h),

                /// ADD / DEDUCT TOGGLE
                Obx(
                  () => Row(
                    children: [
                      _creditToggle(
                        title: "Add",
                        selected: isAdd.value,
                        onTap: () => isAdd.value = true,
                      ),
                      SizedBox(width: 12.w),
                      _creditToggle(
                        title: "Deduct",
                        selected: !isAdd.value,
                        onTap: () => isAdd.value = false,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),

                /// AMOUNT LABEL
                Text(
                  "Amount",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),

                SizedBox(height: 6.h),

                /// AMOUNT FIELD
                TextField(
                  controller: creditController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.grayTextColor,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.grayTextColor.withAlpha(
                          (0.3 * 255).round(),
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.grayTextColor.withAlpha(
                          (0.3 * 255).round(),
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 26.h),

                /// ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          side: BorderSide(
                            color: AppColors.grayTextColor.withAlpha(
                              (0.4 * 255).round(),
                            ),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.grayTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(
                            creditController.text.trim(),
                          );

                          if (amount == null || amount <= 0) {
                            CommonToast.show(
                              "Please enter a valid amount",
                              type: ToastType.warning,
                            );
                            return;
                          }

                          // Close dialog first
                          Get.back();

                          // Then perform the operation
                          await _updateUserCredit(
                            userId: user.uid,
                            amount: amount,
                            isAdd: isAdd.value,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _creditToggle({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withAlpha((0.12 * 255).round())
                : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.grayTextColor.withAlpha((0.3 * 255).round()),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.grayTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ FIXED: Deduct now subtracts from current (credit) instead of adding to spent
  Future<void> _updateUserCredit({
    required String userId,
    required double amount,
    required bool isAdd,
  }) async {
    final userRef = FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(userId);

    try {
      CommonLoader.show();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          throw Exception("User not found");
        }

        final data = snapshot.data()!;

        final double currentCredit = (data['credit'] ?? 0).toDouble();
        final double remainingCredit = (data['remaining_credits'] ?? 0)
            .toDouble();

        if (isAdd) {
          /// ✅ ADD CREDIT
          transaction.update(userRef, {
            'credit': currentCredit + amount,
            'remaining_credits': remainingCredit + amount,
            'updated_at': FieldValue.serverTimestamp(),
          });
        } else {
          ///  DEDUCT CREDIT - Validate before deducting
          if (remainingCredit < amount) {
            throw Exception(
              "Cannot deduct ₹${amount.toStringAsFixed(2)}. Only ₹${remainingCredit.toStringAsFixed(2)} remaining credit available.",
            );
          }

          if (currentCredit < amount) {
            throw Exception(
              "Cannot deduct ₹${amount.toStringAsFixed(2)}. Current credit is only ₹${currentCredit.toStringAsFixed(2)}.",
            );
          }

          transaction.update(userRef, {
            'credit': currentCredit - amount,
            'remaining_credits': remainingCredit - amount,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      });

      CommonLoader.hide();

      CommonToast.show(
        isAdd
            ? "₹${amount.toStringAsFixed(2)} credit added successfully"
            : "₹${amount.toStringAsFixed(2)} credit deducted successfully",
        type: ToastType.success,
      );

      // Send notifications for credit changes
      try {
        final userSnapshot = await FirebaseFirestore.instance
            .collection(AppConstantStrings.userCollection)
            .doc(userId)
            .get();
        final token = (userSnapshot.data()?['fcm_token'] as String?) ?? '';
        final uid = (userSnapshot.data()?['uid'] as String?) ?? '';
        if (token.trim().isNotEmpty) {
          if (isAdd) {
            await AdminNotificationService().sendCreditAdded(
              token,
              amount.toInt(),
                uid
            );
          } else {
            await AdminNotificationService().sendCreditUsed(
              token,
              amount.toInt(),
                uid
            );
            // low balance check
            final remaining =
                (userSnapshot.data()?['remaining_credits'] as num?)
                    ?.toDouble() ??
                0.0;
            if (remaining < 10000) {
              await AdminNotificationService().sendLowCredit(token,uid);
            }
          }
        }
      } catch (e) {
        log('Failed to send credit change notification: $e');
      }
    } catch (e) {
      CommonLoader.hide();

      // Clean error message - remove "Exception: " prefix
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      log("ERROR MESSAGE: $errorMessage");
      // Show user-friendly error message
      CommonToast.show("Please check amount ", type: ToastType.error);
    }
  }

  Widget _infoRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Row(
      children: [
        /// LEFT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                leftValue,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.grayTextColor,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 30.w),

        /// RIGHT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rightLabel,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                rightValue,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.grayTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black.withAlpha((0.05 * 255).round()),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          color: Colors.black.withAlpha((0.05 * 255).round()),
        ),
      ],
    );
  }

  Widget _creditCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.black.withAlpha((0.05 * 255).round()),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 13.sp, color: AppColors.grayTextColor),
            ),
            SizedBox(height: 8.h),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetCreditConfirm(BuildContext context, String userId) {
    Get.dialog(
      AlertDialog(
        title: const Text("Reset Credit"),
        content: const Text(
          "This will reset all credit values to zero.\n\n"
          "This action cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Get.back();
              await _resetUserCredit(userId);
            },
            child: const Text("Reset"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _resetUserCredit(String userId) async {
    final userRef = FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(userId);

    try {
      CommonLoader.show();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          throw Exception("User not found");
        }

        transaction.update(userRef, {
          'credit': 0,
          'used_credits': 0,
          'remaining_credits': 0,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });

      CommonLoader.hide();

      CommonToast.show(
        "User credit reset successfully",
        type: ToastType.success,
      );
    } catch (e) {
      CommonLoader.hide();

      // Clean error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      CommonToast.show(errorMessage, type: ToastType.error);
    }
  }
}
