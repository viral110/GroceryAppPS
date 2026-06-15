import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class NotificationsView extends StatelessWidget {
  final String userId;

  const NotificationsView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: CommonAppBar(title: "Notifications"),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No Notifications"));
          }

          // 🔥 Group data
          Map<String, List<DocumentSnapshot>> grouped = {
            "Today": [],
            "Yesterday": [],
            "Older": [],
          };

          DateTime now = DateTime.now();

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['createdAt'];

            if (timestamp == null) continue;

            DateTime date = timestamp.toDate();

            if (_isToday(date, now)) {
              grouped["Today"]!.add(doc);
            } else if (_isYesterday(date, now)) {
              grouped["Yesterday"]!.add(doc);
            } else {
              grouped["Older"]!.add(doc);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection("Today", grouped["Today"]!),
              _buildSection("Yesterday", grouped["Yesterday"]!),
              _buildSection("Older", grouped["Older"]!),
            ],
          );
        },
      ),
    );
  }

  // ================= SECTION =================

  Widget _buildSection(String title, List<DocumentSnapshot> list) {
    if (list.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.grayTextColor,
          ),
        ),
        const SizedBox(height: 10),

        ...list.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _notificationTile(
              title: data['title'] ?? "",
              body: data['body'] ?? "",
              time: _formatTime(data['createdAt']),
            ),
          );
        }).toList(),
      ],
    );
  }

  // ================= TILE =================

  Widget _notificationTile({
    required String title,
    required String body,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.notifications,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grayTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grayTextColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= HELPERS =================

  bool _isToday(DateTime date, DateTime now) {
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date, DateTime now) {
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";

    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}