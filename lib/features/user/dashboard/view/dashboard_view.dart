import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:online_groceries_app/features/user/account/view/account_view.dart';
import 'package:online_groceries_app/features/user/explore/view/explore_view.dart';
import 'package:online_groceries_app/features/user/favourite/view/favourite_view.dart';
import 'package:online_groceries_app/features/user/home/view/home_view.dart';
import 'package:online_groceries_app/features/user/my_cart/view/my_cart_view.dart';
import 'package:online_groceries_app/utils/app_colors.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages =  [
    GroceryHomeScreen(),
    ExploreView(),
    MyCartView(),
    FavouriteView(),
    AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          height: 2,
        ),
        unselectedLabelStyle: TextStyle(
          height: 2,
            fontSize: 12.sp,
            color: AppColors.textColor,
            fontWeight: FontWeight.w600
        ),
        selectedItemColor: AppColors.primary,
        backgroundColor: AppColors.whiteColor,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items:  [
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svg/shop_icon.svg"),
            activeIcon:SvgPicture.asset("assets/svg/shop_icon.svg",color: AppColors.primary,) ,
            label: "Shop",
          ),
          BottomNavigationBarItem(
            icon:SvgPicture.asset("assets/svg/explore_icon.svg"),
            activeIcon:SvgPicture.asset("assets/svg/explore_icon.svg",color: AppColors.primary,) ,
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svg/cart_icon.svg"),
            activeIcon:SvgPicture.asset("assets/svg/cart_icon.svg",color: AppColors.primary,) ,
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svg/favourite_icon.svg"),
            activeIcon:SvgPicture.asset("assets/svg/favourite_icon.svg",color: AppColors.primary,) ,
            label: "Favourite",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svg/account_icon.svg"),
            activeIcon:SvgPicture.asset("assets/svg/account_icon.svg",color: AppColors.primary,) ,
            label: "Account",
          ),
        ],
      ),
    );
  }
}
