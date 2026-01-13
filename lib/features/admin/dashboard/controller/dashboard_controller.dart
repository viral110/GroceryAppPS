import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
enum AdminTab { dashboard, users, orders, products,promoCode,store,settings }

class AdminDashboardController extends GetxController {
  var selectedTab = AdminTab.dashboard.obs;

  void changeTab(AdminTab tab) {
    selectedTab.value = tab;
  }
  RxInt selectedMonth = DateTime.now().month.obs;
  RxInt selectedYear = DateTime.now().year.obs;

  RxBool isLoadingStats = true.obs;
  RxMap<String, dynamic> stats = <String, dynamic>{}.obs;

  List<int> years =
  List.generate(5, (i) => DateTime.now().year - i);

  @override
  void onInit() {
    fetchDashboardStats();
    super.onInit();
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
  }

  void changeYear(int year) {
    selectedYear.value = year;
  }

  /// 🔥 Dashboard Cards Stats
  Future<void> fetchDashboardStats() async {
    isLoadingStats.value = true;

    final usersSnap =
    await FirebaseFirestore.instance.collection(AppConstantStrings.userCollection).where("isAdmin", isEqualTo: false).get();
    final ordersSnap =
    await FirebaseFirestore.instance.collection(AppConstantStrings.orderCollection).get();
    final productsSnap =
    await FirebaseFirestore.instance.collection(AppConstantStrings.productsCollection).get();

    double revenue = 0;
    for (var doc in ordersSnap.docs) {
      revenue += (doc['total_amount'] as num?)?.toDouble() ?? 0;
    }

    stats.value = {
      'users': usersSnap.docs.length,
      'orders': ordersSnap.docs.length,
      'products': productsSnap.docs.length,
      'revenue': revenue,
    };

    isLoadingStats.value = false;
  }

  /// 🔥 Month–Year wise Orders & Revenue
  Future<Map<String, List<double>>> fetchMonthlyChart() async {
    final start = DateTime(selectedYear.value, selectedMonth.value, 1);
    final end = DateTime(selectedYear.value, selectedMonth.value + 1, 1);

    final snap = await FirebaseFirestore.instance
        .collection('orders')
        .where('created_at',
        isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('created_at',
        isLessThan: Timestamp.fromDate(end))
        .get();

    final days = DateTime(selectedYear.value, selectedMonth.value + 1, 0).day;

    List<double> orders = List.filled(days, 0);
    List<double> revenue = List.filled(days, 0);

    for (var doc in snap.docs) {
      final date = (doc['created_at'] as Timestamp).toDate();
      final index = date.day - 1;

      orders[index] += 1;
      revenue[index] +=
          (doc['total_amount'] as num?)?.toDouble() ?? 0;
    }

    return {
      'orders': orders,
      'revenue': revenue,
    };
  }
}


