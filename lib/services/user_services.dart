import 'dart:async';
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

  /// ✅ Real-time credit sync subscription
  static StreamSubscription<DocumentSnapshot>? _creditSyncSubscription;

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
      // ✅ Cancel credit sync when user logs out
      await _cancelCreditSync();
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

  /// ✅ START REAL-TIME CREDIT SYNC
  /// This listens to Firestore changes and updates local storage automatically
  static void startCreditSync(String userId) {
    // Cancel any existing subscription
    _cancelCreditSync();

    log("Starting real-time credit sync for user: $userId");

    _creditSyncSubscription = FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) async {
            if (!snapshot.exists) {
              log("User document not found");
              return;
            }

            final firestoreData = snapshot.data()!;
            final localUser = getUserFromHive();

            // Check if credits have changed
            final double firestoreCredit =
                (firestoreData['credit'] as num?)?.toDouble() ?? 0.0;
            final double firestoreUsedCredits =
                (firestoreData['used_credits'] as num?)?.toDouble() ?? 0.0;
            final double firestoreRemainingCredits =
                (firestoreData['remaining_credits'] as num?)?.toDouble() ?? 0.0;

            final double localCredit = localUser.credit ?? 0.0;
            final double localUsedCredits = localUser.usedCredits ?? 0.0;
            final double localRemainingCredits =
                localUser.remainingCredits ?? 0.0;

            // ✅ If any credit values differ, update local storage
            if (firestoreCredit != localCredit ||
                firestoreUsedCredits != localUsedCredits ||
                firestoreRemainingCredits != localRemainingCredits) {
              log("🔄 Credits changed in Firestore. Syncing...");
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
              await setUserInHive(localUser);

              log("✅ User credits synced successfully");
            }
          },
          onError: (error) {
            log("❌ Error in credit sync listener: $error");
          },
        );
  }

  /// ✅ CANCEL CREDIT SYNC
  static Future<void> _cancelCreditSync() async {
    if (_creditSyncSubscription != null) {
      await _creditSyncSubscription!.cancel();
      _creditSyncSubscription = null;
      log("Credit sync subscription cancelled");
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

    // ✅ Start credit sync after user login
    startCreditSync(user.uid);
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

  /// Update the FCM token for a user in Firestore and sync local Hive copy.
  Future<void> updateFcmToken(String userId, String? token) async {
    try {
      final docRef = firestore.collection(AppConstantStrings.userCollection).doc(userId);

      // Use update when token field already exists or set to empty string if removing
      await docRef.set({'fcm_token': token ?? ''}, SetOptions(merge: true));

      // Update Hive local copy if it matches
      final local = getUserFromHive();
      if (local.uid.isNotEmpty && local.uid == userId) {
        local.fcmToken = token ?? '';
        await setUserInHive(local);
      }
    } catch (e) {
      log('Failed to update FCM token for user $userId: $e');
    }
  }

  logOut() async {
    CommonLoader.show();
    try {
      // await Purchases.logOut();
    } catch (e) {
      log(e.toString());
    }

    await _box.delete(userKey);

    // ✅ Cancel credit sync on logout
    await _cancelCreditSync();

    await FirebaseAuth.instance.signOut();

    CommonLoader.hide();
  }

  bool isUserLoggedIn() {
    return UserService.getUserFromHive().uid.isNotEmpty;
  }
}
