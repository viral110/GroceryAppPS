import 'package:get/get.dart';

enum AdminTab { dashboard, users, orders, products, store,settings }

class AdminDashboardController extends GetxController {
  var selectedTab = AdminTab.dashboard.obs;

  void changeTab(AdminTab tab) {
    selectedTab.value = tab;
  }
}
