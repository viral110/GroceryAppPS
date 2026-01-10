import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/widgets/details_tab.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
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
                  _UserOrdersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _UserOrdersTab extends StatelessWidget {
  const _UserOrdersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: const [
        _UserOrderCard(
          orderId: "ORD-1023",
          date: "15 Jan 2026",
          items: "Rice 5kg, Oil 1L",
          amount: "₹ 1,250",
          status: "Completed",
        ),
        _UserOrderCard(
          orderId: "ORD-1024",
          date: "16 Jan 2026",
          items: "Milk 2L, Bread ×2",
          amount: "₹ 850",
          status: "Pending",
        ),
        _UserOrderCard(
          orderId: "ORD-1025",
          date: "17 Jan 2026",
          items: "Apple 1kg, Banana 1kg",
          amount: "₹ 2,100",
          status: "Cancelled",
        ),
      ],
    );
  }
}

class _UserOrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final String items;
  final String amount;
  final String status;

  const _UserOrderCard({
    required this.orderId,
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
    return Container(
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
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to Order Details Screen
                },
                child: Container(
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}


