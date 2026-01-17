import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/order_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/view/order_success_view.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class CheckoutBottomSheet extends StatelessWidget {
  // final String totalPrice;
   CheckoutBottomSheet({super.key});
  final orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    "Checkout",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 25),
                  ),
                ],
              ),
            ),
            const Divider(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => _rowItem(
                      title: "Delivery",
                      value: orderController.selectedPaymentMethod.value,
                      onTap: () => showDeliveryMethodSheet(context),
                    ),
                  ),

                  const Divider(height: 35),

                  _rowItem(
                    title: "Promo Code",
                    value: "Pick discount",
                    onTap: () => showPromoCodeSheet(context),
                  ),
                  const Divider(height: 35),

                  Obx(
                        () => _rowItem(
                      title: "Delivery Date",
                      value: orderController.formattedDate,
                      onTap: () => showSelectDate(context),
                    ),
                  ),
                  Obx(() {
                    if (!orderController.isPromoApplied.value) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          _rowItem(
                            title: "Promo Applied",
                            value: orderController.appliedPromoCode.value,
                          ),
                          const SizedBox(height: 6),
                          _rowItem(
                            title: "Discount",
                            value:
                                "- ${AppConstantStrings.rupeeSymbol} ${orderController.promoDiscount.value.toStringAsFixed(2)}",
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 35),
                  _rowItem(
                    title: "Total Cost",
                    value:
                        "${AppConstantStrings.rupeeSymbol} ${orderController.finalPayable.toStringAsFixed(2)}",

                    // "${AppConstantStrings.rupeeSymbol} ${cartController.totalPrice.toStringAsFixed(2)}",
                    isBold: true,
                  ),

                  const Divider(height: 35),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      text: "By placing an order you agree to our\n",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff7C7C7C),
                      ),
                      children: [
                        TextSpan(
                          text: "Terms",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        TextSpan(
                          text: " And ",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff7C7C7C),
                          ),
                        ),
                        TextSpan(
                          text: "Conditions",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  FutureBuilder<double>(
                    future: getAvailableCreditFromFirebase(),
                    builder: (context, snapshot) {
                      final credit = snapshot.data ?? 0.0;

                      return Text(
                        "• Your available credit is ${AppConstantStrings.rupeeSymbol} "
                            "${credit.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff7C7C7C),
                        ),
                      );
                    },
                  ),


                  const SizedBox(height: 10),
                  CommonButton(
                    title: "Place Order",
                    onTap: () async {
                      final selectedMethod =
                          orderController.selectedPaymentMethod.value;

                      log("Selected Method: $selectedMethod");
                      if (selectedMethod.isEmpty ||
                          selectedMethod == "Select Method") {
                        CommonToast.show(
                          "Please select a payment method",
                          type: ToastType.error,
                        );

                        return;
                      }
                      if (orderController.formattedDate.isEmpty) {
                        // No method selected
                        CommonToast.show(
                          "Please select a order date",
                          type: ToastType.error,
                        );

                        return;
                      }
                      try {
                        if (selectedMethod == "Cash on Delivery") {
                          await orderController.placeOrder(
                            paymentMethod: "COD",
                          );

                          await orderController.onOrderSuccess();
                        } else if (selectedMethod == "Online Payment") {
                          var sucess = await orderController
                              .processRazorpayPayment();

                        } else if (selectedMethod == "Pay on Credit") {
                          final double orderAmount =
                              orderController.finalPayable;
                          final double availableCredit =
                          await getAvailableCreditFromFirebase();

                          if (orderAmount > availableCredit) {
                            CommonToast.show(
                              "Insufficient credit. Available credit is ₹${availableCredit.toStringAsFixed(2)}",
                              type: ToastType.error,
                            );
                            return;
                          }
                          else{
                            await orderController.payUsingCredit(
                              orderController.finalPayable,
                            );

                            await orderController.placeOrder(
                              paymentMethod: "Credit",
                            );
                            await orderController.onOrderSuccess();

                          }
                        }
                      } catch (e,s) {
                        print(e);
                        print(s);
                        CommonLoader.hide(); // ✅ ALWAYS HIDE LOADER
                        Get.back(closeOverlays: true);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const OrderFailedDialog(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
   Future<void> showSelectDate(BuildContext context) async {
     final pickedDate = await showDatePicker(
       context: context,
       initialDate: DateTime.now(),
       firstDate: DateTime.now(),
       lastDate: DateTime.now().add(const Duration(days: 365)),
     );

     if (pickedDate != null) {
       orderController.selectedDate.value = pickedDate;
     }
   }

  double _getAvailableCredit() {
    final user = UserService.getUserFromHive();
    final totalCredit = user.credit ?? 0;
    final spentCredit = user.usedCredits ?? 0;
    return (totalCredit - spentCredit).toDouble();
  }

  static Widget _rowItem({
    required String title,
    String? value,
    Widget? valueWidget,
    bool isBold = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xff7C7C7C),
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          valueWidget ??
              Row(
                children: [
                  Text(
                    value ?? "",
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 25,
                    color: AppColors.textColor,
                  ),
                ],
              ),
        ],
      ),
    );
  }

  void showDeliveryMethodSheet(BuildContext context) {
    final orderController = Get.find<OrderController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Obx(
              () => _deliveryRadioTile(
                title: "Cash on Delivery",
                orderController: orderController,
              ),
            ),
            Obx(
              () => _deliveryRadioTile(
                title: "Online Payment",
                orderController: orderController,
              ),
            ),
            Obx(
              () => _deliveryRadioTile(
                title: "Pay on Credit",
                orderController: orderController,
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void showPromoCodeSheet(BuildContext context) {
    // final controller = Get.find<CartController>();

    final orderController = Get.find<OrderController>();
    final promoController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apply Promo Code",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: promoController,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: "Enter promo code",

                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CommonButton(
              title: "Apply",
              onTap: () async {
                if (promoController.text.trim().isEmpty) return;

                FocusScope.of(context).unfocus();

                await orderController.applyPromo(promoController.text.trim());

                log("IS APPLIED: ${orderController.isPromoApplied.value}");
                if (orderController.isPromoApplied.value) {
                  log("IS APPLIED: ${orderController.isPromoApplied.value}");
                  Get.close(1); // close promo sheet
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryRadioTile({
    required String title,
    required OrderController orderController,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Radio<String>(
        value: title,
        groupValue: orderController.selectedPaymentMethod.value,
        activeColor: AppColors.primary,
        onChanged: (value) {
          orderController.selectedPaymentMethod.value = value!;
          Get.back(); // close sheet after selection
        },
      ),
      onTap: () {
        orderController.selectedPaymentMethod.value = title;
        Get.back();
      },
    );
  }
   Future<double> getAvailableCreditFromFirebase() async {
     final userId = UserService.getUserFromHive().uid;

     final doc = await FirebaseFirestore.instance
         .collection('users')
         .doc(userId)
         .get();

     if (!doc.exists) return 0.0;

     final data = doc.data()!;
     final remainingCredit =
     (data['remaining_credits'] ?? 0).toDouble();

     return remainingCredit;
   }


}
