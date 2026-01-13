import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:online_groceries_app/features/admin/orders/controller/admin_orderview_controller.dart';
import 'package:online_groceries_app/features/admin/orders/view/admin_order_detail_view.dart';

import '../../../../models/order_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminOrdersView extends StatelessWidget {
  AdminOrdersView({super.key});

  final controller = Get.put(AdminOrdersController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Orders",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(
              width: 400.w,
              child: TextField(
                onChanged: controller.updateSearch, // 🔥 CONNECT
                decoration: InputDecoration(
                  hintText: "Search order (ID / User)",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          ],
        ),

        SizedBox(height: 20.h),

        /// 🔥 TABS (GetX)
        Obx(() => Row(
          children: List.generate(
            controller.tabs.length,
                (index) => _tabItem(
              controller.tabs[index],
              isActive: controller.selectedTab.value == index,
              onTap: () => controller.changeTab(index),
            ),
          ),
        )),

        SizedBox(height: 16.h),

        _tableHeader(),
        SizedBox(height: 8.h),

        /// 🔥 FIRESTORE DATA
        Expanded(
          child: Obx(
                () => StreamBuilder<QuerySnapshot>(
              stream: controller.ordersQuery.snapshots(),
              builder: (context, snapshot) {

                // 1️⃣ Loader
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2️⃣ Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                // 3️⃣ Docs extract
                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                // 🔥 SEARCH + LIST must be reactive
                return Obx(() {
                  final query = controller.searchQuery.value;

                  final orders = docs
                      .map((e) =>
                      OrderModel.fromMap(e.data() as Map<String, dynamic>))
                      .where((order) {
                    if (query.isEmpty) return true;

                    final orderId = order.orderId?.toLowerCase() ?? '';
                    final userName =
                        order.deliveryAddress?.name?.toLowerCase() ?? '';

                    return orderId.contains(query) ||
                        userName.contains(query);
                  })
                      .toList();

                  if (orders.isEmpty) {
                    return const Center(child: Text("No matching orders"));
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (_, index) => _orderRow(orders[index]),
                  );
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// ---------------- TAB ITEM ----------------
  Widget _tabItem(String title,
      {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
          isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textColor,
          ),
        ),
      ),
    );
  }

  /// ---------------- TABLE HEADER ----------------
  Widget _tableHeader() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: const Row(
        children: [
          Expanded(child: Text("Order ID", style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text("Customer", style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text("Date", style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text("Items", style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text("Amount", style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text("Status", style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  /// ---------------- ORDER ROW ----------------
  Widget _orderRow(OrderModel order) {
    final itemsText =
    order.items.map((e) => "${e.productName} ×${e.quantity}").join(", ");

    Color statusColor = order.orderStatus == "Completed"
        ? Colors.green
        : order.orderStatus == "Cancelled"
        ? Colors.red
        : AppColors.primary;

    return GestureDetector(
      onTap: (){
        Get.to(()=>OrderDetailView(orderId: order.orderId ??"",));
      },
      child: Container(
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Expanded(child: Padding(
              padding:  EdgeInsets.only(left: 10),
              child: Text("#${order.orderId}"),
            )),
            Expanded(child: Padding(
              padding:  EdgeInsets.only(left: 10),
              child: Text(order.deliveryAddress?.name ?? "User"),
            )),
            Expanded(
              child: Padding(
                padding:  EdgeInsets.only(left: 10),
                child: Text(
                  DateFormat('dd MMM yyyy').format(order.createdAt!),
                ),
              ),
            ),
            Expanded(child: Padding(
              padding:  EdgeInsets.only(left: 10),
              child: Text(itemsText),
            )),
            Expanded(child: Padding(
              padding:  EdgeInsets.only(left: 10),
              child: Text("₹ ${order.totalAmount.toStringAsFixed(0)}"),
            )),
            Expanded(
              child: Text(
                order.orderStatus!,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _showStatusDialog(order),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Change Status",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- STATUS DIALOG ----------------
  void _showStatusDialog(OrderModel order) {
    RxString selectedStatus = order.orderStatus!.obs;

    Get.dialog(
      AlertDialog(
        title: const Text("Change Order Status"),
        content: Obx(
              () => Wrap(
            spacing: 10,
            children: controller.orderStatusList.map((status) {
              final isSelected = selectedStatus.value == status;
              return GestureDetector(
                onTap: () => selectedStatus.value = status,
                child: Chip(
                  label: Text(status),
                  backgroundColor: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.grey.shade200,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await controller.updateOrderStatus(
                orderId: order.orderId!,
                status: selectedStatus.value,
              );
              Get.back();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  /// ---------------- SEARCH BOX ----------------
  Widget _searchBox() {
    return Container(
      height: 60.h,
      width: 400.w,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 18, color: Colors.grey),
          SizedBox(width: 6),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          blurRadius: 12,
          color: Colors.black.withOpacity(0.04),
        ),
      ],
    );
  }
}
