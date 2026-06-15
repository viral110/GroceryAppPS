import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/admin/auth/view/admin_login_view.dart';
import 'package:online_groceries_app/features/admin/dashboard/view/admin_dashboard.dart';
import 'package:online_groceries_app/features/user/auth/view/login_view.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import 'package:online_groceries_app/features/user/welcome/view/welcome_view.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    log("MOUNTED:${mounted}");
    if (!mounted) return;

    final user = UserService.getUserFromHive();
    log("USER:${user.uid}");

    if (user != null && user.uid.isNotEmpty) {
      // ✅ SYNC USER CREDITS FROM FIRESTORE (for mobile users only)
      if (!kIsWeb) {
        await _syncUserCreditsFromFirestore(user.uid);
      }

      if (kIsWeb) {
        Get.off(() => AdminDashboardView());
      } else {
        Get.off(() => MainScreen());
      }
    } else {
      if (kIsWeb) {
        Get.off(() => AdminLoginView());
      } else {
        Get.off(() => LoginScreen());
      }
    }
  }

  /// ✅ SYNC USER CREDITS FROM FIRESTORE
  /// This ensures local Hive data stays in sync with Firestore changes
  Future<void> _syncUserCreditsFromFirestore(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppConstantStrings.userCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        log("User document not found in Firestore");
        return;
      }

      final firestoreData = doc.data()!;
      final localUser = UserService.getUserFromHive();

      // Check if credits have changed
      final double firestoreCredit =
          (firestoreData['credit'] as num?)?.toDouble() ?? 0.0;
      final double firestoreUsedCredits =
          (firestoreData['used_credits'] as num?)?.toDouble() ?? 0.0;
      final double firestoreRemainingCredits =
          (firestoreData['remaining_credits'] as num?)?.toDouble() ?? 0.0;

      final double localCredit = localUser.credit ?? 0.0;
      final double localUsedCredits = localUser.usedCredits ?? 0.0;
      final double localRemainingCredits = localUser.remainingCredits ?? 0.0;

      // ✅ If any credit values differ, update local storage
      if (firestoreCredit != localCredit ||
          firestoreUsedCredits != localUsedCredits ||
          firestoreRemainingCredits != localRemainingCredits) {
        log("Credits changed in Firestore. Syncing...");
        log(
          "Old: credit=$localCredit, used=$localUsedCredits, remaining=$localRemainingCredits",
        );
        log(
          "New: credit=$firestoreCredit, used=$firestoreUsedCredits, remaining=$firestoreRemainingCredits",
        );

        // Update local user model with new credit values
        localUser.credit = firestoreCredit;
        localUser.usedCredits = firestoreUsedCredits;
        localUser.remainingCredits = firestoreRemainingCredits;

        // Save updated user to Hive
        await UserService.setUserInHive(localUser);

        log("User credits synced successfully");
      } else {
        log("Credits are in sync. No update needed.");
      }
    } catch (e) {
      log("Error syncing user credits: $e");
      // Don't block navigation if sync fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset("assets/png/logo.jpg",width: 200.w,),),
    );
  }
}
