import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/features/user/my_details/controller/my_details_controller.dart';

class MyDetailsView extends StatefulWidget {
  const MyDetailsView({super.key});

  @override
  State<MyDetailsView> createState() => _MyDetailsViewState();
}

class _MyDetailsViewState extends State<MyDetailsView> {
  MyDetailsController controller = Get.put(MyDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "My Details"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),

              CommonTextField(
                label: "First Name",
                hint: "Enter first name",
                controller: controller.firstNameController,
              ),

              const SizedBox(height: 16),

              /// LAST NAME
              CommonTextField(
                label: "Last Name",
                hint: "Enter last name",
                controller: controller.lastNameController,
              ),

              const SizedBox(height: 16),

              /// EMAIL
              CommonTextField(
                label: "Email",
                hint: "Enter your email",
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                isReadOnly: true,
              ),

              const SizedBox(height: 16),

              /// MOBILE
              CommonTextField(
                label: "Mobile Number",
                hint: "Enter mobile number",
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                isReadOnly: true,
              ),

              const SizedBox(height: 24),

              /// ADDRESS TITLE
              const Text(
                "Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              /// AREA
              CommonTextField(
                label: "Area",
                hint: "Enter area",
                controller: controller.areaController,
              ),

              const SizedBox(height: 16),

              /// CITY
              CommonTextField(
                label: "City",
                hint: "Enter city",
                controller: controller.cityController,
              ),

              const SizedBox(height: 16),

              /// STATE
              CommonTextField(
                label: "State",
                hint: "Enter state",
                controller: controller.stateController,
              ),

              const SizedBox(height: 16),

              /// PINCODE
              CommonTextField(
                label: "Pincode",
                hint: "Enter pincode",
                controller: controller.pincodeController,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 30.h),

              /// UPDATE BUTTON
              CommonButton(title: "Update", onTap: controller.updateProfile),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
