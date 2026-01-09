import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/view/order_success_view.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class CheckoutBottomSheet extends StatelessWidget {
  const CheckoutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =Get.put(CartController());
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

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
                    child:
                    const Icon(Icons.close, size: 25),
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
                  Obx(() => _rowItem(
                    title: "Delivery",
                    value: controller.selectedPaymentMethod.value,
                    onTap: () => showDeliveryMethodSheet(context),
                  )),

                  const Divider(height: 35),

                  _rowItem(
                    title: "Promo Code",
                    value: "Pick discount",
                    onTap: () => showPromoCodeSheet(context),
                  ),
                  const Divider(height: 35),
                  _rowItem(
                    title: "Total Cost",
                    value: "₹13.97",
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
                              color: Color(0xff7C7C7C)
                          ),
                          children: [
                            TextSpan(
                                text: "Terms",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor
                                )
                            ),
                            TextSpan(
                                text: " And ",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff7C7C7C)
                                )
                            ),
                            TextSpan(
                                text: "Conditions",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor
                                )
                            ),
                          ]
                      ),),

                  const SizedBox(height: 4),
                  Text(
                    "• Your available credit is ₹12,000",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff7C7C7C),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CommonButton(
                    title: "Place Order",
                    onTap: () {
                      Get.to(() => OrderSuccessView());
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
                      fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w600,
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
    final controller = Get.find<CartController>();


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
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            Obx(() => _deliveryRadioTile(
              title: "Cash on Delivery",
              controller: controller,
            )),
            Obx(() => _deliveryRadioTile(
              title: "Online Payment",
              controller: controller,
            )),
            Obx(() => _deliveryRadioTile(
              title: "Pay on Credit",
              controller: controller,
            )),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  void showPromoCodeSheet(BuildContext context) {
    final controller = Get.find<CartController>();
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
              decoration:  InputDecoration(
                hintText: "Enter promo code",

                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),

                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 20),
            CommonButton(
              title: "Apply",
              onTap: () {
                if (promoController.text == "SAVE10") {
                  controller.discount.value = 10;
                  Get.back();
                } else {
                  Get.snackbar("Invalid", "Promo code not valid");
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
    required CartController controller,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Radio<String>(
        value: title,
        groupValue: controller.selectedPaymentMethod.value,
        activeColor: AppColors.primary,
        onChanged: (value) {
          controller.selectedPaymentMethod.value = value!;
          Get.back(); // close sheet after selection
        },
      ),
      onTap: () {
        controller.selectedPaymentMethod.value = title;
        Get.back();
      },
    );
  }


}
