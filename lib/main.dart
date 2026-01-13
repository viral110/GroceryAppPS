import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:online_groceries_app/features/user/splash_screen.dart';
import 'package:online_groceries_app/firebase_options.dart';
import 'package:online_groceries_app/services/razorpay_service.dart';
import 'package:online_groceries_app/services/user_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Razorpay Payment Service
  Get.put(RazorpayPaymentService());
  await Hive.initFlutter();
  await Hive.openBox(boxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: kIsWeb
          ? const Size(1440, 1024) // WEB (Admin)
          : const Size(414, 896), // MOBILE (User App)      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Gilroy",
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.w800),
            titleLarge: TextStyle(fontWeight: FontWeight.w700),
            bodyMedium: TextStyle(fontWeight: FontWeight.w400),
            labelLarge: TextStyle(fontWeight: FontWeight.w500),
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
