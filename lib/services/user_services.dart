import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/models/user_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

const boxName = "creds";

class UserService {
  static final _box = Hive.box(boxName);
  static const userKey = "userDetails";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //========Hive============
  static Future setUserInHive(UserModel user) async {
    await _box.put(
      userKey,
      user.toJson(setInHive: true),
    );
  }

  static UserModel getUserFromHive() {
    var data = _box.get(userKey);
    if (data != null) {
      return UserModel.fromJson(_box.get(userKey), id: data["uid"]);
    } else {
      return UserModel();
    }
  }
  //======== Logout / Clear Local User ============

  static Future<void> clearUserFromHive() async {
    try {
      await _box.delete(userKey);
    } catch (e) {
      print("Error clearing user from Hive: $e");
    }
  }

  // Future<void> updateFcmToken(String uid) async {
  //   try {
  //     String? token = await FirebaseMessaging.instance.getToken();
  //
  //     if (token != null) {
  //       await firestore.collection('users').doc(uid).update({
  //         'fcm_token': token,
  //       });
  //       UserModel user = getUserFromHive();
  //       user.fcmToken = token;
  //       updateUser(user);
  //       print("✅ FCM token updated: $token");
  //     }
  //   } catch (e) {
  //     print("❌ Error updating FCM token: $e");
  //   }
  // }

  // static Future setIsFirstTimeHive() async {
  //   await _box.put("isFirstTime", false);
  // }

  // static bool getIsFirstTimeFromHive() {
  //   return _box.get("isFirstTime") ?? true;
  // }

  // static Future<bool> isUserValid() async {
  //   UserModel user = await getUserFromSharedPrefs();
  //   return user.uid.isNotEmpty;
  // }

  // static Future<UserModel> getUserFromSharedPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? json = prefs.getString(userKey);
  //   UserModel user = UserModel.fromJson(jsonDecode(json ?? ""));
  //   await setUserInHive(user);
  //   return user;
  // }

  //======== Firebase ============
  Future<UserModel> getUserFromDbById(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> data = await firestore
        .collection(AppConstantStrings.userCollection)
        .doc(userId)
        .get();

    if (data.exists) {
      UserModel user = UserModel.fromJson(data.data()!, id: data.id);
      return user;
    } else {
      return UserModel();
    }
  }

  Future<void> setUserinDb(UserModel user) async {
    await firestore
        .collection(AppConstantStrings.userCollection)
        .doc(user.uid)
        .set(user.toJson());
    setUserInHive(user);
  }

  Future<void> setAdminUserinDb(UserModel user) async {
    await firestore
        .collection(AppConstantStrings.userCollection)
        .doc(user.uid)
        .set(user.toJson());
  }

  Future<void> updateUser(UserModel user) async {
    await firestore
        .collection(AppConstantStrings.userCollection)
        .doc(user.uid)
        .update(
          user.toJson(),
        );
    await setUserInHive(user);
  }

  logOut() async {
    CommonLoader.show();
    try {
      // await Purchases.logOut();
    } catch (e) {
      log(e.toString());
    }

    await _box.delete(userKey);
    await FirebaseAuth.instance.signOut();

    CommonLoader.hide();

  }

  // Future<void> deleteAccount(String uid, String password) async {
  //   try {
  //     AppLoader.showLoadingDialog();
  //
  //     final user = FirebaseAuth.instance.currentUser!;
  //
  //     // 1️⃣ Re-authenticate user (required for sensitive operations)
  //     final credential = EmailAuthProvider.credential(
  //       email: user.email!,
  //       password: password, // Ask the user for their password
  //     );
  //     await user.reauthenticateWithCredential(credential);
  //
  //     // 2️⃣ Delete Firestore user document
  //     await firestore.collection(AppConstantStrings.userCollection).doc(uid).delete();
  //
  //     // 3️⃣ Delete Firebase Auth user
  //     await user.delete();
  //
  //     // 4️⃣ Delete local storage
  //     await _box.delete(userKey);
  //     //AnalyticsService.appRemove();
  //     // 5️⃣ Close loader and navigate
  //     AppLoader.closeLoadingDialog();
  //   //  Get.offAll(() => const SplashScreen());
  //   } on FirebaseAuthException catch (e) {
  //     AppLoader.closeLoadingDialog();
  //     if (e.code == 'requires-recent-login') {
  //       showMessage("Please log in again before deleting your account.");
  //     } else {
  //       showMessage(e.message ?? 'Something went wrong');
  //     }
  //   } catch (e) {
  //     AppLoader.closeLoadingDialog();
  //     showMessage( e.toString());
  //   }
  // }

  bool isUserLoggedIn() {
    return UserService.getUserFromHive().uid.isNotEmpty;
  }
}
