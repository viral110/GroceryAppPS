import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: showBack
          ? GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 19,
          color: AppColors.textColor,
        ),
      )
          : SizedBox(),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size(double.infinity, 8),
        child: Divider(height: 0),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
