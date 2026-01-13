import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AdminOrdersController extends GetxController {
  RxInt selectedTab = 0.obs;
  RxString searchQuery = ''.obs; // 🔥 ADD THIS

  final List<String> tabs = [
    "All",
    "New Requests",
    "Ongoing",
    "Completed",
    "Cancelled",
  ];

  final List<String> orderStatusList = [
    "Pending",
    "Ongoing",
    "Completed",
    "Cancelled",
  ];

  Query get ordersQuery {
    Query query = FirebaseFirestore.instance
        .collection(AppConstantStrings.orderCollection);
    switch (selectedTab.value) {
      case 1:
        query = query.where('order_status', isEqualTo: 'Pending');
        break;
      case 2:
        query = query.where('order_status', isEqualTo: 'Ongoing');
        break;
      case 3:
        query = query.where('order_status', isEqualTo: 'Completed');
        break;
      case 4:
        query = query.where('order_status', isEqualTo: 'Cancelled');
        break;
    }

    return query;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void updateSearch(String value) {
    searchQuery.value = value.toLowerCase().trim();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstantStrings.orderCollection)
        .where('order_id', isEqualTo: orderId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'order_status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }
}
