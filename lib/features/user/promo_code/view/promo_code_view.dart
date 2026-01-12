import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/features/user/promo_code/controller/promo_code_controller.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

import '../../../../common_widgets/common_app_bar.dart';

class PromoCodeView extends StatelessWidget {
  PromoCodeView({super.key});

  final PromoCodeController promoController = Get.put(PromoCodeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CommonAppBar(title: "Promo Code"),
      body: Obx(() {
        if (promoController.isLoading.value) {
          return SizedBox.shrink();
        }

        if (promoController.promoCodes.isEmpty) {
          return const Center(child: Text("No promo codes available"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: promoController.promoCodes.length,
          itemBuilder: (context, index) {
            final promo = promoController.promoCodes[index];
            return CouponCard(
              title: promoController.getDiscountTitle(promo),
              description: promoController.getDescription(promo),
              code: promo.code,
              expiry:
                  "${promo.endDate.day}/${promo.endDate.month}/${promo.endDate.year}",
              discountText: promoController.getDiscountBadge(promo),
              onApply: () {
                Clipboard.setData(ClipboardData(text: promo.code));
                log("Applied ${promo.code}");
              },
            );
            //  CouponCard(
            //               title: "${promo.discountValue}% OFF",
            //               description: "On orders above ₹${promo.minOrderAmount}",
            //               code: promo.code,
            //               expiry:
            //                   "${promo.endDate.day}/${promo.endDate.month}/${promo.endDate.year}",
            //               discountText: "${promo.discountValue}%\nOFF",
            //               onApply: () {
            //                 log("Applied ${promo.code}");
            //               },
            //             );
          },
        );
      }),
    );
  }
}

class CouponCard extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final String expiry;
  final String discountText;
  final VoidCallback onApply;

  const CouponCard({
    super.key,
    required this.title,
    required this.description,
    required this.code,
    required this.expiry,
    required this.discountText,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Main Card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              /// Discount Section
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    discountText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              /// Dashed Divider
              SizedBox(
                width: 1,
                height: double.infinity,
                child: CustomPaint(painter: _DashedLinePainter()),
              ),

              /// Coupon Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                      const Spacer(),

                      /// Code + Apply
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onApply,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Copy",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(
                        "Valid until $expiry",
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Left Cut
        Positioned(left: -8, top: 52, child: _cutCircle()),

        /// Right Cut
        Positioned(right: -8, top: 52, child: _cutCircle()),
      ],
    );
  }

  Widget _cutCircle() {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Color(0xffF5F5F5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    double dashHeight = 5;
    double dashSpace = 5;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
