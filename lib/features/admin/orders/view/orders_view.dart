import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  int selectedTab = 0;
  final List<String> orderStatusList = [
    "Pending",
    "Ongoing",
    "Completed",
    "Cancelled",
  ];

  final tabs = [
    "All",
    "New Requests",
    "Ongoing",
    "Completed",
    "Cancelled",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
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
            Row(
              children: [
                _searchBox(),
              ],
            ),
          ],
        ),

        SizedBox(height: 20.h),

        /// TABS
        Row(
          children: List.generate(
            tabs.length,
                (index) => _tabItem(
              tabs[index],
              isActive: selectedTab == index,
              onTap: () {
                setState(() {
                  selectedTab = index;
                });
              },
            ),
          ),
        ),

        SizedBox(height: 16.h),

        /// TABLE HEADER
        _tableHeader(),

        SizedBox(height: 8.h),

        /// TABLE DATA
        ..._ordersByTab(),
      ],
    );
  }

  // ---------------- DATA BY TAB (UI ONLY) ----------------

  List<Widget> _ordersByTab() {
    switch (selectedTab) {
      case 1:
        return [
          _orderRow("Pending", "Rice 5kg, Oil 1L"),
        ];
      case 2:
        return [
          _orderRow("Ongoing", "Milk 2L, Bread ×2"),
        ];
      case 3:
        return [
          _orderRow("Completed", "Apple 1kg, Banana 1kg"),
        ];
      case 4:
        return [
          _orderRow("Cancelled", "Sugar 2kg"),
        ];
      default:
        return [
          _orderRow("Pending", "Rice 5kg, Oil 1L"),
          _orderRow("Ongoing", "Milk 2L, Bread ×2"),
          _orderRow("Completed", "Apple 1kg, Banana 1kg"),
          _orderRow("Cancelled", "Sugar 2kg"),
        ];
    }
  }

  // ---------------- UI WIDGETS ----------------

  Widget _tabItem(
      String title, {
        required bool isActive,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
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
            color: isActive
                ? AppColors.primary
                : AppColors.textColor,
          ),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: const [
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

  Widget _orderRow(String status, String items) {
    Color statusColor;
    switch (status) {
      case "Completed":
        statusColor = Colors.green;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppColors.primary;
    }

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Expanded(child: Text("#ORD-1023")),
          const Expanded(child: Text("Amit Patel")),
          const Expanded(child: Text("15 Jan 2026")),
          Expanded(child: Text(items)),
          const Expanded(child: Text("₹ 1,250")),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _showStatusChangeDialog(status);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color:AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Change States",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
  void _updateOrderStatus(String? newStatus) {
    if (newStatus == null) return;

    setState(() {
      // UI only – later replace with API
      selectedTab = orderStatusList.indexOf(newStatus);
    });
  }

  void _showStatusChangeDialog(String currentStatus) {
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                "Change Order Status",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select new status",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.grayTextColor,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  /// STATUS OPTIONS
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: orderStatusList.map((status) {
                      final bool isSelected = selectedStatus == status;

                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedStatus = status;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              /// ACTION BUTTONS
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.grayTextColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _updateOrderStatus(selectedStatus);
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


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
                isDense: true,
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
