import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/admin/user_tab/controller/user_list_controller.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/add_user_view.dart';
import 'package:online_groceries_app/features/admin/user_tab/view/user_detail_view.dart';
import 'package:online_groceries_app/models/user_model.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

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
            Spacer(),
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
            SizedBox(width: 20.w,),
            SizedBox(
              width: 140.w,
              child: CommonButton(
                title: "Add User",
                onTap: () {
                  Get.to(() =>  AdminAddAdminView());
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
              final filteredUsers =
              controller.filterUsers(snapshot.data!);

              if (filteredUsers.isEmpty) {
                return const Center(child: Text("No matching users"));
              }

              return Column(
                children: filteredUsers.map((user) {
                  return GestureDetector(
                    onTap: (){
                      Get.to(()=>AdminUserDetailView(userModel: user,));
                    },
                    child: _userRow(
                      "${user.firstName} ${user.lastName}",
                      user.email ?? "",
                      user.mobileNumber ?? "",
                      "₹${user.credit}",
                    ),
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
        children:  [
          Expanded(child: Text("Name", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.sp))),
          Expanded(child: Text("Email", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.sp))),
          Expanded(child: Text("Mobile", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.sp))),
          Expanded(child: Text("Credit Amount", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.sp))),
        ],
      ),
    );
  }

  Widget _userRow(String name, String email, String mobile,String creditAmount) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Expanded(child: Text(email)),
          Expanded(child: Text(mobile)),
          Expanded(child: Text(creditAmount)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    );
  }
}
