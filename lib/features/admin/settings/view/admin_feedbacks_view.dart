import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class AdminFeedbacksView extends StatelessWidget {
  const AdminFeedbacksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: const CommonAppBar(title: "User Feedbacks"),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(AppConstantStrings.feedbacksCollection)
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No feedbacks found"));
            }

            final feedbacks = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(24.w),
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final data = feedbacks[index].data() as Map<String, dynamic>;

                return _feedbackCard(
                  name: data['uid'] ?? 'Anonymous',
                  rating: data['rating'] ?? 0,
                  message: data['message'] ?? '',
                  date: _formatDate(data['created_at']),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// ---------------- DATE FORMAT ----------------
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return "${date.day} ${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return months[month - 1];
  }

  /// ---------------- FEEDBACK CARD ----------------
  Widget _feedbackCard({
    required String name,
    required int rating,
    required String message,
    required String date,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// USER & DATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.grayTextColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          /// RATING
          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                Icons.star,
                size: 18,
                color: index < rating
                    ? Colors.amber
                    : Colors.grey.shade300,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          /// MESSAGE
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grayTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
