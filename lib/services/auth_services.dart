import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';

import '../models/user_model.dart';
import '../services/user_services.dart';

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserModel?> _handleUserLogin(UserCredential credential) async {
    try {
      final firebaseUser = credential.user;

      if (firebaseUser == null || firebaseUser.uid.isEmpty) {
        log("Firebase user is null");
        return null;
      }

      UserModel? user;

      try {
        user = await UserService().getUserFromDbById(firebaseUser.uid);
      } catch (_) {
        user = null;
      }

      if (user == null || user.uid.isEmpty) {
        user = UserModel(
          uid: firebaseUser.uid,
          // Apple-safe fallbacks
          email: firebaseUser.email ?? 'apple_${firebaseUser.uid}@user.com',
          firstName: firebaseUser.displayName ?? 'Apple User',
          createdAt: DateTime.now(),
        );

        if (kIsWeb) {
          await UserService().setAdminUserinDb(user);
        } else {
          await UserService().setUserinDb(user);
        }
      }

      // save in Hive
      await UserService.setUserInHive(user);

      return user;
    } catch (e, s) {
      log("Error handling user login: $e");
      log("StackTrace: $s");
      return null;
    }
  }

  /// 🔹 Handle Firebase Authentication errors
  void _handleAuthError(FirebaseAuthException e) {
    Map<String, String> errorMessages = {
      'user-not-found': 'No user found for that email.',
      'wrong-password': 'Wrong password provided.',
      'invalid-email': 'Invalid email format.',
      'invalid-credential': 'Invalid credentials.',
      'email-already-in-use': 'The account already exists for that email.',
      'weak-password': 'The password provided is too weak.',
    };
    CommonToast.show(
      errorMessages[e.code] ?? 'An unexpected error occurred: ${e.message}',
      type: ToastType.error,
    );
  }

  /// 🔹 Sign Up with Email & Password
  Future<bool> addUser({
    required UserModel user,
    required String password,
  }) async {
    try {
      UserCredential credential = await firebaseAuth
          .createUserWithEmailAndPassword(
            email: user.email!,
            password: password,
          );

      user.uid = credential.user!.uid;
      await UserService().setAdminUserinDb(user);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e, s) {
      log("Error during sign-up: $e");
      log("Error during sign-up: $s");
      CommonToast.show("An unexpected error occurred.", type: ToastType.error);

      return false;
    }
  }

  /// 🔹 Sign In with Email & Password
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await firebaseAuth.currentUser!.reload();

      return await _handleUserLogin(credential);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      log("Error during sign-in: $e");
      return null;
    }
  }

  /// 🔹 Send Password Reset Email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      // CommonToast.show("Password reset email sent. Please check your inbox.",type: ToastType.success);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  /// 🔹 Send Email Verification
  Future<void> sendEmailVerificationLink() async {
    if (firebaseAuth.currentUser != null) {
      await firebaseAuth.currentUser!.sendEmailVerification();
    }
  }

  /// 🔹 Sign Out (email/google)
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();

      // 🔹 Clear local user data
      await UserService.clearUserFromHive();
    } catch (e) {
      log("Error during sign-out: $e");
    }
  }
}
