import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Send Feedback"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rate your experience",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),

              SizedBox(height: 12.h),

              /// STAR RATING
              Row(
                children: List.generate(
                  5,
                      (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.star,
                        size: 34,
                        color: index < selectedRating
                            ? Colors.amber
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                selectedRating == 0
                    ? "Tap to rate"
                    : "$selectedRating out of 5 stars",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.grayTextColor,
                ),
              ),

              SizedBox(height: 30.h),

              /// FEEDBACK FIELD
              CommonTextField(
                label: "Your Feedback",
                hint: "Write your feedback here",
                maxLines: 5,
                controller: TextEditingController(),
              ),

              SizedBox(height: 40.h),

              /// SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: CommonButton(
                  title: "Submit Feedback",
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
