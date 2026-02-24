import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/admin/user_tab/controller/add_user_controller.dart';
import 'package:online_groceries_app/features/admin/user_tab/controller/user_list_controller.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/add_user_view.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/user_detail_view.dart';
import 'package:online_groceries_app/models/user_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class UserListView extends StatelessWidget {
  UserListView({super.key});
  final controller = Get.put(UserListController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Users",
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
                onChanged: (value) {
                  controller.searchQuery.value = value;
                },
                decoration: InputDecoration(
                  hintText: "Search by name, email or mobile",
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
              width: 140.w,
              child: CommonButton(
                title: "Add User",
                onTap: () {
                  Get.to(() => const AdminAddAdminView());
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        _tableHeader(),

        SizedBox(height: 12.h),
        StreamBuilder<List<UserModel>>(
          stream: controller.getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No users found"));
            }

            return Obx(() {
              final filteredUsers = controller.filterUsers(snapshot.data!);

              if (filteredUsers.isEmpty) {
                return const Center(child: Text("No matching users"));
              }

              return Column(
                children: filteredUsers.map((user) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AdminUserDetailView(userModel: user));
                    },
                    child: _userRow(user),
                  );
                }).toList(),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(child: Text("Name", style: _headerText())),
          Expanded(child: Text("Business", style: _headerText())), // ✅ NEW
          Expanded(child: Text("Email", style: _headerText())),
          Expanded(child: Text("Mobile", style: _headerText())),
          Expanded(child: Text("Credit", style: _headerText())),
          SizedBox(
            width: 90.w,
            child: Text("User Access", style: _headerText()),
          ),
          SizedBox(
            width: 120.w,
            child: Text("Actions", style: _headerText()),
          ), // ✅ NEW
        ],
      ),
    );
  }

  TextStyle _headerText() =>
      TextStyle(fontWeight: FontWeight.w600, fontSize: 17.sp);

  Widget _userRow(UserModel user) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(child: Text("${user.firstName} ${user.lastName}")),
          Expanded(
            child: Text(
              user.businessName ?? "-", // ✅ NEW
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: Text(user.email ?? "")),
          Expanded(child: Text(user.mobileNumber ?? "")),
          Expanded(child: Text("₹${user.credit}")),

          // ===== ENABLE / DISABLE SWITCH =====
          SizedBox(
            width: 90.w,
            child: Switch(
              value: user.isEnable,
              activeColor: AppColors.primary,
              onChanged: (value) {
                _updateUserStatus(userId: user.uid!, isActive: value);
              },
            ),
          ),

          // ✅ ACTION BUTTONS (EDIT & DELETE)
          SizedBox(
            width: 120.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// EDIT BUTTON
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: "Edit User",
                  onPressed: () {
                    Get.to(() => AdminAddAdminView(userToEdit: user));
                  },
                ),

                /// DELETE BUTTON
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: "Delete User",
                  onPressed: () {
                    _showDeleteConfirmation(user);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ DELETE CONFIRMATION DIALOG
  void _showDeleteConfirmation(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete User"),
        content: Text(
          "Are you sure you want to delete ${user.firstName} ${user.lastName}?\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              final addUserController = Get.put(AddUserController());
              addUserController.deleteUser(user.uid!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    await FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .doc(userId)
        .update({
          "isEnable": isActive,
          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(0.05)),
      ],
    );
  }
}
