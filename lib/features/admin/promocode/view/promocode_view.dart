import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/features/admin/promocode/controller/promocode_controller.dart';
import 'package:online_groceries_app/services/admin_notification_service.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';


class PromoListView extends StatelessWidget {
  PromoListView({super.key});

  final controller = Get.put(PromoController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Text(
                "Promo Codes",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColor,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 400.w,
                child: TextField(
                  onChanged: controller.onSearch,
                  decoration: InputDecoration(
                    hintText: "Search by promo code",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.whiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              SizedBox(
                width: 160.w,
                child: CommonButton(
                  title: "Add Promo",
                  onTap: () {
                    showPromoDialog(context);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          _tableHeader(),

          SizedBox(height: 12.h),

          /// PROMO LIST
          StreamBuilder<List<PromoModel>>(
            stream: controller.getPromos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No promo codes found"));
              }

              return Obx(() {
                final promos = controller.filterPromos(snapshot.data!);

                if (promos.isEmpty) {
                  return const Center(child: Text("No matching promo codes"));
                }

                return Column(
                  children: promos.map((promo) {
                    return _promoRow(
                      promo.code,
                      promo.discountType.toLowerCase() == 'flat'
                          ? "₹${promo.discountValue}"
                          : "${promo.discountValue}%",
                      "₹${promo.minOrderAmount}",
                      "${promo.usedCount}",
                      onEdit: () => showPromoDialog(context, promo: promo),
                      onDelete: () => controller.deletePromo(promo.id),
                    );
                  }).toList(),
                );
              });
            },
          )

        ],
      ),
    );
  }
  void showPromoDialog(BuildContext context, {PromoModel? promo}) {
    final codeCtrl = TextEditingController(text: promo?.code);
    final discountCtrl =
    TextEditingController(text: promo?.discountValue.toString());
    final minOrderCtrl =
    TextEditingController(text: promo?.minOrderAmount.toString());

    bool isFlat = promo?.discountType == 'flat';

    DateTime startDate = promo?.startDate ?? DateTime.now();
    DateTime endDate =
        promo?.endDate ?? DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.whiteColor,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              promo == null ? "Add Promo Code" : "Edit Promo Code",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Promo Code"),
                    _inputField(codeCtrl, hint: "e.g. SAVE50"),

                    _label("Discount Value"),
                    _inputField(discountCtrl,
                        hint: "e.g. 50 or 10",
                        keyboard: TextInputType.number),

                    _label("Minimum Order Amount"),
                    _inputField(minOrderCtrl,
                        hint: "e.g. 500",
                        keyboard: TextInputType.number),

                    const SizedBox(height: 12),

                    /// DATE PICKERS
                    Row(
                      children: [
                        Expanded(
                          child: _dateTile(
                            title: "Start Date",
                            date: startDate,
                            onTap: () async {
                              final picked =
                              await pickDate(context, startDate);
                              if (picked != null) {
                                setState(() => startDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateTile(
                            title: "End Date",
                            date: endDate,
                            onTap: () async {
                              final picked =
                              await pickDate(context, endDate);
                              if (picked != null) {
                                setState(() => endDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// SWITCHES
                    _switchRow(
                      title: isFlat ? "Flat Discount (₹)" : "Percentage Discount (%)",
                      value: isFlat,
                      onChanged: (v) => setState(() => isFlat = v),
                    ),

                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: AppColors.grayTextColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  try {
                    /// PROMO CODE
                    if (codeCtrl.text.trim().isEmpty) {
                      CommonToast.show(
                        "Please enter promo code",
                        type: ToastType.warning,
                      );
                      return;
                    }

                    /// DISCOUNT VALUE
                    if (discountCtrl.text.trim().isEmpty) {
                      CommonToast.show(
                        "Please enter discount value",
                        type: ToastType.warning,
                      );
                      return;
                    }

                    final discountValue = double.tryParse(discountCtrl.text);
                    if (discountValue == null || discountValue <= 0) {
                      CommonToast.show(
                        "Enter a valid discount value",
                        type: ToastType.warning,
                      );
                      return;
                    }

                    /// MIN ORDER
                    if (minOrderCtrl.text.trim().isEmpty) {
                      CommonToast.show(
                        "Please enter minimum order amount",
                        type: ToastType.warning,
                      );
                      return;
                    }

                    final minOrder = double.tryParse(minOrderCtrl.text);
                    if (minOrder == null || minOrder <= 0) {
                      CommonToast.show(
                        "Enter a valid minimum order amount",
                        type: ToastType.warning,
                      );
                      return;
                    }

                    /// % VALIDATION
                    if (!isFlat && discountValue > 100) {
                      CommonToast.show(
                        "Percentage discount cannot be more than 100%",
                        type: ToastType.warning,
                      );
                      return;
                    }

                    /// DATE VALIDATION
                    if (endDate.isBefore(startDate)) {
                      CommonToast.show(
                        "End date must be after start date",
                        type: ToastType.warning,
                      );
                      return;
                    }

                    /// 🔥 DATA MAP (COMPLETE)
                    final data = {
                      'code': codeCtrl.text.trim().toUpperCase(),
                      'discountValue': discountValue,
                      'minOrderAmount': minOrder,
                      'discountType': isFlat ? 'flat' : 'percentage',
                      'usedCount': promo?.usedCount ?? 0,
                      'startDate': Timestamp.fromDate(startDate),
                      'endDate': Timestamp.fromDate(endDate),
                      'createdAt': Timestamp.now(),
                    };

                    final ref =
                    FirebaseFirestore.instance.collection(AppConstantStrings.promoCodeCollection);

                    if (promo == null) {
                      await ref.add(data);
                      // Notify all users about new promo
                      try {
                        final title = "🎉 New Offer: ${data['code']}";
                        final body = "Get ${data['discountValue']}${data['discountType']=='flat'?'₹':'%'} off. Min order: ₹${data['minOrderAmount']}";
                        await AdminNotificationService().sendNewOffer(title, body);
                      } catch (e) {
                        debugPrint('Failed to send promo notification: $e');
                      }
                    } else {
                      await ref.doc(promo.id).update(data);
                    }
                    Get.back();

                    CommonToast.show(
                      promo == null
                          ? "Promo added successfully"
                          : "Promo updated successfully",
                      type: ToastType.success,
                    );

                    Get.back();
                  } catch (e) {
                    debugPrint("🔥 PROMO SAVE ERROR => $e");

                    CommonToast.show(
                      "Something went wrong. Please try again",
                      type: ToastType.warning,
                    );
                  }
                },


                child: const Text(
                  "Save Promo",
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
        ),
      ),
    );
  }

  Widget _inputField(
      TextEditingController controller, {
        String? hint,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.whiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grayTextColor.withAlpha((0.2*255).round())),
          ),
        ),
      ),
    );
  }

  Widget _dateTile({
    required String title,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grayTextColor.withAlpha((0.3*255).round())),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.grayTextColor)),
            const SizedBox(height: 6),
            Text(
              "${date.day}-${date.month}-${date.year}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textColor),
      ),
      activeThumbColor: AppColors.primary,
      value: value,
      onChanged: onChanged,
    );
  }

  /// TABLE HEADER
  Widget _tableHeader() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(child: _headerText("Code")),
          Expanded(child: _headerText("Discount")),
          Expanded(child: _headerText("Min Order")),
          Expanded(child: _headerText("UsedCount")),
          Expanded(child: _headerText("Actions")),
        ],
      ),
    );
  }

  /// PROMO ROW
  Widget _promoRow(
      String code,
      String discount,
      String minOrder,
      String usedCount,
     {
        required VoidCallback onEdit,
        required VoidCallback onDelete,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(child: Text(code)),
          Expanded(child: Text(discount)),
          Expanded(child: Text(minOrder)),
          Expanded(child: Text(usedCount)),

          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Text _headerText(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17.sp),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          color: Colors.black.withAlpha((0.05*255).round()),
        ),
      ],
    );
  }

  Future<DateTime?> pickDate(
      BuildContext context,
      DateTime initialDate,
      ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
  }

}
