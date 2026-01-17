import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/admin/orders/view/admin_order_detail_view.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/widgets/details_tab.dart';
import 'package:online_groceries_app/features/user/my_orders/view/order_details_view.dart';
import 'package:online_groceries_app/models/order_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
import '../../../../models/user_model.dart';


class AdminUserDetailView extends StatelessWidget {
  final  UserModel  userModel;
  const AdminUserDetailView({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F6FA),
        appBar: const CommonAppBar(title: "User Profile"),
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
                  _UserOrdersTab(userId: userModel.uid),                ],
              ),
            ),
          ],
        ),
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
            .map((doc) =>
            OrderModel.fromMap(doc.data() as Map<String, dynamic>))
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
              sortOrderId: order.shortOrderId ??"--",
              orderId: order.orderId ?? "--",
              date: order.createdAt != null
                  ? DateFormat('dd MMM yyyy').format(order.createdAt!)
                  : "--",
              items: itemsText,
              amount: "₹ ${order.totalAmount.toStringAsFixed(0)}",
              status: order.orderStatus ?? "--",
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
  final String date;
  final String items;
  final String amount;
  final String status;

  const _UserOrderCard({
    required this.orderId,
    required this.sortOrderId,
    required this.date,
    required this.items,
    required this.amount,
    required this.status,
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
    return GestureDetector(
      onTap: (){
        Get.to(()=>AdminOrderDetailView(orderId: orderId,));
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ORDER ID + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#$orderId",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
              ],
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

            SizedBox(height: 14.h),

            /// AMOUNT + VIEW DETAILS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
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

              ],
            ),
          ],
        ),
      ),
    );
  }
}


