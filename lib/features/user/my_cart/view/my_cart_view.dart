import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/user/my_cart/controller/my_cart_controller.dart';
import 'package:online_groceries_app/features/user/my_cart/view/widgets/check_out_bottmsheet.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

import '../../../../common_widgets/common_app_bar.dart';



/// ================= VIEW =================
class MyCartView extends StatelessWidget {
  MyCartView({super.key});

  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "My Cart",showBack: false,),
      body: Column(
        children: [
          /// CART LIST
          Expanded(
            child: Obx(
                  () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 36),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(item.image, height: 55.h),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// TITLE + REMOVE
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      controller.removeItem(index),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            /// SUBTITLE
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// QTY + PRICE
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          controller.decrement(index),
                                      child:
                                      _qtyButton(Icons.remove),
                                    ),
                                    const SizedBox(width: 10),
                                    Obx(
                                          () => Text(
                                        controller.quantities[index]
                                            .toString(),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () =>
                                          controller.increment(index),
                                      child: _qtyButton(
                                        Icons.add,
                                        isAdd: true,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  item.price,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          /// BOTTOM BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) =>
                    const CheckoutBottomSheet(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 30),
                    Text(
                      "Go to Checkout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withOpacity(0.2),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Text(
                        "₹12.96",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// QTY BUTTON (UNCHANGED UI)
  static Widget _qtyButton(
      IconData icon, {
        bool isAdd = false,
      }) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isAdd ? Colors.green : Colors.grey.shade600,
      ),
    );
  }
}

/// ================= MODEL =================
class CartItem {
  final String title;
  final String subtitle;
  final String price;
  final String image;

  CartItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.image,
  });
}


