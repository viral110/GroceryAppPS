import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/user/dashboard/view/dashboard_view.dart';
import '../../../../services/auth_services.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var isPasswordVisible = false.obs;

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> loginWithEmailAndPassword() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // VALIDATIONS
    if (email.isEmpty) {
      CommonToast.show("Please enter your email", type: ToastType.warning);
      return;
    }

    if (!_isEmailValid(email)) {
      CommonToast.show("Please enter a valid email", type: ToastType.warning);

      return;
    }

    if (password.isEmpty) {
      CommonToast.show("Please enter your password", type: ToastType.warning);
      return;
    }

    if (password.length < 6) {
      CommonToast.show(
        "Password must be at least 6 characters",
        type: ToastType.warning,
      );

      return;
    }

    CommonLoader.show();

    var user = await AuthServices().signInWithEmailAndPassword(email, password);

    CommonLoader.hide();
    if (user != null) {
      if ((user.uid ?? "").isNotEmpty) {
        Get.offAll(() => MainScreen());
        // _checkLatestSubscription();
      }
    }
    // else {
    //   Get.snackbar("Login Failed", "Something went wrong. Please try again.");
    // }
  }

  void forgotPassword() {
    // Au
  }
}
