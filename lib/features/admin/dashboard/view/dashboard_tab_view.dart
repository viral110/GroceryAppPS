import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            "Overview of your grocery store",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grayTextColor,
            ),
          ),

          SizedBox(height: 30.h),

          /// STATS CARDS
          Row(
            children: [
              _statCard("Total Users", "1,240"),
              SizedBox(width: 16.w),
              _statCard("Total Orders", "356"),
              SizedBox(width: 16.w),
              _statCard("Products", "98"),
              SizedBox(width: 16.w),
              _statCard("Revenue", "₹ 1,24,500"),
            ],
          ),

          SizedBox(height: 30.h),

          /// RECENT ORDERS
          Text(
            "Recent Orders",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 12.h),

          Container(
            padding: EdgeInsets.all(20.w),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _orderRow("ORD-1021", "Amit Patel", "₹ 850", "Delivered"),
                _divider(),
                _orderRow("ORD-1022", "Rahul Shah", "₹ 1,240", "Pending"),
                _divider(),
                _orderRow("ORD-1023", "Neha Verma", "₹ 560", "Cancelled"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------- Widgets -------------------

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grayTextColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderRow(
      String orderId,
      String customer,
      String price,
      String status,
      ) {
    Color statusColor;
    switch (status) {
      case "Delivered":
        statusColor = Colors.green;
        break;
      case "Pending":
        statusColor = AppColors.primary;
        break;
      default:
        statusColor = Colors.red;
    }

    return Row(
      children: [
        Expanded(child: Text(orderId)),
        Expanded(child: Text(customer)),
        Expanded(child: Text(price)),
        Expanded(
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Divider(color: Colors.grey.shade200),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          blurRadius: 20,
          color: Colors.black.withOpacity(0.05),
        )
      ],
    );
  }
}
