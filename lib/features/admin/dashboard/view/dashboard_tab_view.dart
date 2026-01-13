import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:online_groceries_app/features/admin/dashboard/controller/dashboard_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class DashboardTab extends StatelessWidget {
  DashboardTab({super.key});

  final AdminDashboardController controller = Get.put(AdminDashboardController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard",
            style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800),
          ),

          SizedBox(height: 20.h),

          Obx(() {
            if (controller.isLoadingStats.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = controller.stats;

            return Row(
              children: [
                _statCard("Users", data['users'].toString()),
                SizedBox(width: 16.w),
                _statCard("Orders", data['orders'].toString()),
                SizedBox(width: 16.w),
                _statCard("Products", data['products'].toString()),
                SizedBox(width: 16.w),
                _statCard(
                  "Revenue",
                  "₹ ${NumberFormat('#,##0').format(data['revenue'])}",
                ),
              ],
            );
          }),

          SizedBox(height: 30.h),

          _filters(),

          SizedBox(height: 30.h),

          _ordersGraph(),

          SizedBox(height: 30.h),

          _revenueGraph(),

          SizedBox(height: 30.h),

          /// 🔥 RECENT ORDERS (ORDER VIEW TYPE)
          _recentOrdersTable(),
        ],
      ),
    );
  }

  // ================= RECENT ORDERS TABLE =================

  Widget _recentOrdersTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _graphTitle("Recent Orders", "Latest 5 orders (all statuses)"),
        SizedBox(height: 12.h),

        /// TABLE HEADER
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: _cardDecoration(),
          child: const Row(
            children: [
              Expanded(child: Text("Order ID", style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(child: Text("Customer", style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(child: Text("Date", style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(child: Text("Amount", style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(child: Text("Status", style: TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
        ),

        SizedBox(height: 8.h),

        /// DATA
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .orderBy('created_at', descending: true)
              .limit(5)
              .snapshots(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return _graphLoader();

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text("No recent orders"));
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final status = data['order_status'] ?? 'Pending';

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
                      Expanded(
                        child: Text("#${data['order_id'] ?? '--'}"),
                      ),
                      Expanded(
                        child: Text(
                          data['delivery_address']?['name'] ?? "User",
                        ),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM yyyy').format(
                            (data['created_at'] as Timestamp).toDate(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "₹ ${data['total_amount'] ?? 0}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
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
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ================= STATS CARD =================

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: AppColors.grayTextColor)),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 18),
          SizedBox(width: 10.w),
          Expanded(
            child: Obx(() => DropdownButtonFormField<int>(
              value: controller.selectedMonth.value,
              decoration:  InputDecoration(
                labelText: "Month",
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
             isDense: true,
              ),
              items: List.generate(
                12,
                    (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
                ),
              ),
              onChanged: (v) => controller.changeMonth(v!),
            )),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Obx(() => DropdownButtonFormField<int>(
              value: controller.selectedYear.value,
              decoration: const InputDecoration(
                labelText: "Year",
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                isDense: true,
              ),
              items: controller.years
                  .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (v) => controller.changeYear(v!),
            )),
          ),
        ],
      ),
    );
  }

  // ================= GRAPHS =================

  Widget _ordersGraph() => _graphBlock(
    title: "Orders per Day",
    subtitle: "Number of orders placed each day",
    dataKey: 'orders',
    color: AppColors.primary,
    suffix: "",
  );

  Widget _revenueGraph() => _graphBlock(
    title: "Revenue per Day",
    subtitle: "Total revenue earned per day",
    dataKey: 'revenue',
    color: Colors.green,
    suffix: "k ₹",
    divide: 1000,
  );

  Widget _graphBlock({
    required String title,
    required String subtitle,
    required String dataKey,
    required Color color,
    required String suffix,
    double divide = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _graphTitle(title, subtitle),
        SizedBox(height: 12.h),
        Obx(() => FutureBuilder<Map<String, List<double>>>(
          future: controller.fetchMonthlyChart(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return _graphLoader();
            return _lineChart(
              data: snapshot.data![dataKey]!.map((e) => e / divide).toList(),
              color: color,
              suffix: suffix,
            );
          },
        )),
      ],
    );
  }

  // ================= COMMON =================

  Widget _graphTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 4.h),
        Text(subtitle,
            style: TextStyle(fontSize: 13.sp, color: AppColors.grayTextColor)),
      ],
    );
  }

  Widget _lineChart({
    required List<double> data,
    required Color color,
    required String suffix,
  }) {
    return Container(
      height: 260.h,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                    (i) => FlSpot(i.toDouble(), data[i]),
              ),
              isCurved: true,
              barWidth: 4,
              color: color,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
                ),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _graphLoader() {
    return Container(
      height: 260.h,
      alignment: Alignment.center,
      decoration: _cardDecoration(),
      child: const CircularProgressIndicator(),
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
        ),
      ],
    );
  }
}
