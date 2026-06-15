import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/orders/view/admin_order_detail_view.dart';
import 'package:online_groceries_app/features/admin/user_tab/controller/add_user_controller.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/add_user_view.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/widgets/details_tab.dart';
import 'package:online_groceries_app/features/user/my_orders/view/order_details_view.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
import '../../../../models/user_model.dart';

class AdminUserDetailView extends StatelessWidget {
  final UserModel userModel;
  const AdminUserDetailView({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F6FA),
        appBar: CommonAppBar(
          title: "User Profile",
          actions: [
            /// ✅ EDIT BUTTON
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              tooltip: "Edit User",
              onPressed: () {
                Get.to(() => AdminAddAdminView(userToEdit: userModel));
              },
            ),

            /// ✅ DELETE BUTTON
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Delete User",
              onPressed: () {
                _showDeleteConfirmation(context);
              },
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: Column(
          children: [
            /// TAB BAR
            Container(
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: "Details"),
                  Tab(text: "Orders"),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  UserDetailsTab(userModel),
                  _UserOrdersTab(userId: userModel.uid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete User"),
        content: Text(
          "Are you sure you want to delete ${userModel.firstName} ${userModel.lastName}?\n\nThis action cannot be undone and will also delete all associated data.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              final controller = Get.put(AddUserController());
              controller.deleteUser(userModel.uid!).then((_) {
                // Navigate back to user list after successful deletion
                Get.back();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _UserOrdersTab extends StatelessWidget {
  final String userId;

  const _UserOrdersTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstantStrings.orderCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // 1️⃣ Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2️⃣ Error
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        // 3️⃣ Docs
        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("No orders found"));
        }

        // 4️⃣ Convert Firestore → OrderModel
        final orders = docs
            .map(
              (doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: orders.length,
          itemBuilder: (_, index) {
            final order = orders[index];

            final itemsText = order.items
                .map((e) => "${e.productName} ×${e.quantity}")
                .join(", ");

            return _UserOrderCard(
              sortOrderId: order.shortOrderId ?? "--",
              orderId: order.orderId ?? "--",
              userId: userId,
              date: order.createdAt != null
                  ? DateFormat('dd MMM yyyy').format(order.createdAt!)
                  : "--",
              items: itemsText,
              amount: "₹ ${order.totalAmount.toStringAsFixed(0)}",
              status: order.orderStatus ?? "--",
              totalAmount: order.totalAmount,
              paymentMethod: order.paymentMethod ?? "",
            );
          },
        );
      },
    );
  }
}

class _UserOrderCard extends StatelessWidget {
  final String orderId;
  final String sortOrderId;
  final String userId;
  final String date;
  final String items;
  final String amount;
  final String status;
  final double totalAmount;
  final String paymentMethod;

  const _UserOrderCard({
    required this.orderId,
    required this.sortOrderId,
    required this.userId,
    required this.date,
    required this.items,
    required this.amount,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
  });

  Color _statusColor() {
    switch (status) {
      case "Completed":
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check if payment method is "Credit"
    final bool isCreditOrder = paymentMethod.toLowerCase() == "credit";

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstantStrings.orderCollection)
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        // ✅ Calculate remaining square-off amount
        double squaredOffAmount = 0.0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          squaredOffAmount =
              (data?['squared_off_amount'] as num?)?.toDouble() ?? 0.0;
        }

        final double remainingAmount = totalAmount - squaredOffAmount;
        return GestureDetector(
          onTap: () {
            Get.to(() => AdminOrderDetailView(orderId: orderId));
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black.withOpacity(0.04),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "#$orderId",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      /// DATE
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grayTextColor,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      /// ITEMS
                      Text(
                        items,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(),
                          ),
                        ),
                      ),

                      /// ORDER ID + STATUS
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 250.w,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order Amount:",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                "₹ ${totalAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          if (squaredOffAmount > 0) ...[
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Already Squared Off:",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "₹ ${squaredOffAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 16.h, color: Colors.grey.shade300),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Remaining:",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                Text(
                                  "₹ ${remainingAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h,),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        /// ✅ SQUARE OFF BUTTON - Only show for Credit payment method
                        if (isCreditOrder) ...[
                          SizedBox(width: 10.w),
                          GestureDetector(
                            onTap: () {
                              _showSquareOffDialog(
                                context,
                                orderId: orderId,
                                userId: userId,
                                orderAmount: totalAmount,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.orange,
                              ),
                              child: Text(
                                "Square Off",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ SQUARE OFF DIALOG - Now with dynamic remaining amount
  void _showSquareOffDialog(
    BuildContext context, {
    required String orderId,
    required String userId,
    required double orderAmount,
  }) {
    final TextEditingController amountController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(22.w),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstantStrings.orderCollection)
                  .doc(orderId)
                  .snapshots(),
              builder: (context, snapshot) {
                // ✅ Calculate remaining square-off amount
                double squaredOffAmount = 0.0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  squaredOffAmount =
                      (data?['squared_off_amount'] as num?)?.toDouble() ?? 0.0;
                }

                final double remainingAmount = orderAmount - squaredOffAmount;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Text(
                      "Square Off Order",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    Text(
                      "Enter the amount to square off from this order",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.grayTextColor,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    /// ORDER AMOUNT INFO
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order Amount:",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                "₹ ${orderAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          if (squaredOffAmount > 0) ...[
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Already Squared Off:",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "₹ ${squaredOffAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 16.h, color: Colors.grey.shade300),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Remaining:",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                Text(
                                  "₹ ${remainingAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 22.h),

                    /// AMOUNT LABEL
                    Text(
                      "Square Off Amount",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    /// AMOUNT FIELD
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            "Enter amount (max ₹${remainingAmount.toStringAsFixed(2)})",
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
                            onPressed: remainingAmount <= 0
                                ? null
                                : () async {
                                    final amount = double.tryParse(
                                      amountController.text.trim(),
                                    );

                                    if (amount == null || amount <= 0) {
                                      CommonToast.show(
                                        "Please enter a valid amount",
                                        type: ToastType.warning,
                                      );
                                      return;
                                    }

                                    if (amount > remainingAmount) {
                                      CommonToast.show(
                                        "Amount ₹${amount.toStringAsFixed(2)} exceeds remaining ₹${remainingAmount.toStringAsFixed(2)}",
                                        type: ToastType.error,
                                      );
                                      return;
                                    }

                                    // Close dialog first
                                    Get.back();

                                    // Then perform square off
                                    await _processSquareOff(
                                      userId: userId,
                                      orderId: orderId,
                                      amount: amount,
                                      currentSquaredOff: squaredOffAmount,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: remainingAmount <= 0
                                  ? Colors.grey
                                  : Colors.orange,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              remainingAmount <= 0
                                  ? "Fully Squared Off"
                                  : "Square Off",
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
                );
              },
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// ✅ PROCESS SQUARE OFF - Deduct from spent credits and update order
  Future<void> _processSquareOff({
    required String userId,
    required String orderId,
    required double amount,
    required double currentSquaredOff,
  }) async {
    final userRef = FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(userId);

    final orderRef = FirebaseFirestore.instance
        .collection(AppConstantStrings.orderCollection)
        .doc(orderId);

    try {
      CommonLoader.show();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        final orderSnapshot = await transaction.get(orderRef);

        if (!userSnapshot.exists) {
          throw Exception("User not found");
        }

        if (!orderSnapshot.exists) {
          throw Exception("Order not found");
        }

        final userData = userSnapshot.data()!;
        final double usedCredit = (userData['used_credits'] ?? 0).toDouble();
        final double remainingCredit = (userData['remaining_credits'] ?? 0)
            .toDouble();

        if (usedCredit < amount) {
          throw Exception(
            "Cannot square off ₹${amount.toStringAsFixed(2)}. User has only ₹${usedCredit.toStringAsFixed(2)} in spent credits.",
          );
        }

        /// ✅ Update user credits - Deduct from spent, add back to remaining
        transaction.update(userRef, {
          'used_credits': usedCredit - amount,
          'remaining_credits': remainingCredit + amount,
          'updated_at': FieldValue.serverTimestamp(),
        });

        /// ✅ Update order with squared-off amount
        transaction.update(orderRef, {
          'squared_off_amount': currentSquaredOff + amount,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });

      CommonLoader.hide();

      CommonToast.show(
        "Square off successful - ₹${amount.toStringAsFixed(2)} returned to user",
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
