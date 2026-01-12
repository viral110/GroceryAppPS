import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/models/user_model.dart';
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
                  backgroundColor: AppColors.primary.withOpacity(0.15),
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
                  width: 200.w,
                  child: CommonButton(
                    fontSize: 17.sp,

                    title: "Update User Credit",
                    onTap: () {
                      showUpdateCreditDialog(context, userModel);
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

              final int totalCredit = data['credit'] ?? 0;
              final int spentCredit = data['used_credits'] ?? 0;
              final int pendingCredit =data['remaining_credits'] ?? 0;

              return Row(
                children: [
                  _creditCard(
                    "Current",
                    "₹$totalCredit",
                    Colors.green,
                  ),
                  SizedBox(width: 12.w),
                  _creditCard(
                    "Spent",
                    "₹$spentCredit",
                    Colors.orange,
                  ),
                  SizedBox(width: 12.w),
                  _creditCard(
                    "Pending",
                    "₹$pendingCredit",
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
                rightLabel: "",
                rightValue: "",
              ),
            ],
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
                  keyboardType: TextInputType.number,
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
                        color: AppColors.grayTextColor.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.grayTextColor.withOpacity(0.3),
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
                            color: AppColors.grayTextColor.withOpacity(0.4),
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
                          final amount = int.tryParse(
                            creditController.text.trim(),
                          );

                          if (amount == null || amount <= 0) {
                            CommonToast.show(
                              "Enter valid amount",
                              type: ToastType.warning,
                            );
                            return;
                          }

                          await _updateUserCredit(
                            userId: user.uid,
                            amount: amount,
                            isAdd: isAdd.value,
                          );

                          Get.back();
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
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.grayTextColor.withOpacity(0.3),
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

  Future<void> _updateUserCredit({
    required String userId,
    required int amount,
    required bool isAdd,
  }) async {
    try {
      CommonLoader.show();

      final userRef = FirebaseFirestore.instance
          .collection(AppConstantStrings.userCollection)
          .doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          throw "User not found";
        }

        final int currentCredit = (snapshot.data()?['credit'] ?? 0) as int;

        // ❌ Credit kam hai
        if (!isAdd && currentCredit < amount) {
          throw "Insufficient credit";
        }

        // ✅ New credit calculation
        int newCredit = isAdd
            ? currentCredit + amount
            : currentCredit - amount;

        // 🔒 Safety: credit negative na ho
        if (newCredit < 0) {
          newCredit = 0;
        }

        transaction.update(userRef, {
          "credit": newCredit,
          "updated_at": FieldValue.serverTimestamp(),
        });
      });

      Get.back();
      CommonToast.show(
        isAdd ? "Credit added successfully" : "Credit used successfully",
        type: ToastType.success,
      );
    } catch (e) {
      CommonToast.show(e.toString(), type: ToastType.error);
    } finally {
      CommonLoader.hide();
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
          BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(0.05)),
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
        BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(0.05)),
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
            BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(0.05)),
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
}
