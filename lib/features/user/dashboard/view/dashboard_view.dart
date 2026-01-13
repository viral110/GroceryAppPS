import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/user/account/view/account_view.dart';
import 'package:online_groceries_app/features/user/explore/view/explore_view.dart';
import 'package:online_groceries_app/features/user/favourite/view/favourite_view.dart';
import 'package:online_groceries_app/features/user/home/view/home_view.dart';
import 'package:online_groceries_app/features/user/my_cart/view/my_cart_view.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;
//
//   final List<Widget> _pages =  [
//     GroceryHomeScreen(),
//     ExploreView(),
//     MyCartView(),
//     FavouriteView(),
//     AccountView(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//
//         selectedLabelStyle: TextStyle(
//           fontSize: 12.sp,
//           color: AppColors.primary,
//           fontWeight: FontWeight.w600,
//           height: 2,
//         ),
//         unselectedLabelStyle: TextStyle(
//           height: 2,
//             fontSize: 12.sp,
//             color: AppColors.textColor,
//             fontWeight: FontWeight.w600
//         ),
//         selectedItemColor: AppColors.primary,
//         backgroundColor: AppColors.whiteColor,
//         type: BottomNavigationBarType.fixed,
//
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items:  [
//           BottomNavigationBarItem(
//             icon: SvgPicture.asset("assets/svg/shop_icon.svg"),
//             activeIcon:SvgPicture.asset("assets/svg/shop_icon.svg",color: AppColors.primary,) ,
//             label: "Shop",
//           ),
//           BottomNavigationBarItem(
//             icon:SvgPicture.asset("assets/svg/explore_icon.svg"),
//             activeIcon:SvgPicture.asset("assets/svg/explore_icon.svg",color: AppColors.primary,) ,
//             label: "Explore",
//           ),
//           BottomNavigationBarItem(
//             icon: SvgPicture.asset("assets/svg/cart_icon.svg"),
//             activeIcon:SvgPicture.asset("assets/svg/cart_icon.svg",color: AppColors.primary,) ,
//             label: "Cart",
//           ),
//           BottomNavigationBarItem(
//             icon: SvgPicture.asset("assets/svg/favourite_icon.svg"),
//             activeIcon:SvgPicture.asset("assets/svg/favourite_icon.svg",color: AppColors.primary,) ,
//             label: "Favourite",
//           ),
//           BottomNavigationBarItem(
//             icon: SvgPicture.asset("assets/svg/account_icon.svg"),
//             activeIcon:SvgPicture.asset("assets/svg/account_icon.svg",color: AppColors.primary,) ,
//             label: "Account",
//           ),
//         ],
//       ),
//     );
//   }
// }

class BottomNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstantStrings.userCollection)
          .doc(uid)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>?;

        final bool dashboardEnabled = data?['isEnable'] ?? true;

        if (!dashboardEnabled) {
          return const DashboardBlockedPage();
        }

        return _ActualDashboard();
      },
    );
  }
}

class DashboardBlockedPage extends StatelessWidget {
  const DashboardBlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.block, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                "Dashboard Access Disabled",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Your access to the dashboard has been restricted.\nPlease contact support.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActualDashboard extends StatelessWidget {
  _ActualDashboard({super.key});

  final BottomNavController controller = Get.put(
    BottomNavController(),
    permanent: true,
  );

  final List<Widget> _pages = [
    const GroceryHomeScreen(),
    const ExploreView(),
    MyCartView(),
    const FavouriteView(),
    const AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: _pages[controller.currentIndex.value],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,

          onTap: controller.changeTab,

          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/shop_icon.svg"),
              activeIcon: SvgPicture.asset(
                "assets/svg/shop_icon.svg",
                color: AppColors.primary,
              ),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/explore_icon.svg"),
              activeIcon: SvgPicture.asset(
                "assets/svg/explore_icon.svg",
                color: AppColors.primary,
              ),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/cart_icon.svg"),
              activeIcon: SvgPicture.asset(
                "assets/svg/cart_icon.svg",
                color: AppColors.primary,
              ),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/favourite_icon.svg"),
              activeIcon: SvgPicture.asset(
                "assets/svg/favourite_icon.svg",
                color: AppColors.primary,
              ),
              label: "Favourite",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/account_icon.svg"),
              activeIcon: SvgPicture.asset(
                "assets/svg/account_icon.svg",
                color: AppColors.primary,
              ),
              label: "Account",
            ),
          ],
        ),
      );
    });
  }
}
