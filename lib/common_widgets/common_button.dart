import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets margin;

   CommonButton({
    super.key,
    required this.title,
    required this.onTap,
    this.height = 67,
    this.borderRadius = 19,
    this.backgroundColor = AppColors.primary, // green
    this.textColor = Colors.white,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w600,
    this.margin = const EdgeInsets.symmetric(horizontal: 0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        margin: margin.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize.sp,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
