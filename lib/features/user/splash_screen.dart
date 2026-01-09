import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/auth/view/admin_login_view.dart';
import 'package:online_groceries_app/features/admin/dashboard/view/admin_dashboard.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/welcome/view/welcome_view.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    log("MOUTED:${mounted}");
    if (!mounted) return;
    final user = UserService.getUserFromHive();
    log("USER:$user");
    if (user.uid.isNotEmpty) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        Get.off(() => AdminDashboardView());
      } else {
        Get.off(() => MainScreen());
      }
      // });
    } else {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        Get.off(() => AdminLoginView());
      } else {
        Get.off(() => WelcomeView());
      }
      // });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(child: SvgPicture.asset("assets/svg/logo.svg")),
    );
  }
}
