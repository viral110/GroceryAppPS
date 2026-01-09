import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/features/user/help/view/contactus_view.dart';
import 'package:online_groceries_app/features/user/help/view/customer_support.dart';
import 'package:online_groceries_app/features/user/help/view/faqs_view.dart';
import 'package:online_groceries_app/features/user/help/view/feedback_view.dart';

import '../../../../utils/app_colors.dart';


class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: CommonAppBar(title: "Help"),
      body: Column(
        children: [
          _helpTile(Icons.help_outline, "FAQs",() {
            Get.to(()=>FaqsView());
          },),
          _helpTile(Icons.support_agent, "Customer Support",() {
            Get.to(()=>CustomerSupport());
          },),
          _helpTile(Icons.call, "Contact Us",() {
            Get.to(()=>ContactusView());
          },),
          _helpTile(Icons.feedback_outlined, "Send Feedback",() {
            Get.to(()=>FeedbackView());
          },),
        ],
      ),
    );
  }

  Widget _helpTile(IconData icon, String title,void Function()? onTap) {
    return GestureDetector(
      onTap:onTap ,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
