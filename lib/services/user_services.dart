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
    await _box.put(userKey, user.toJson(setInHive: true));
  }

  static UserModel getUserFromHive() {
    var data = _box.get(userKey);
    if (data != null) {
      log("USER DATA: ${data}");
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

  static Future<void> refreshUserFromFirestore() async {
    final currentUser = getUserFromHive();
    if (currentUser.uid.isEmpty) return;

    final doc = await FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(currentUser.uid)
        .get();

    if (doc.exists) {
      final updatedUser = UserModel.fromJson(doc.data()!, id: doc.id);
      await setUserInHive(updatedUser);
      log("User data refreshed from Firestore: ${updatedUser.toJson()}");
    }
  }

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
        .update(user.toJson());
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

  bool isUserLoggedIn() {
    return UserService.getUserFromHive().uid.isNotEmpty;
  }
}
