import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/common_widgets/common_loader.dart';
import 'package:online_groceries_app/common_widgets/common_textfield.dart';
import 'package:online_groceries_app/common_widgets/common_tost.dart';
import 'package:online_groceries_app/services/user_services.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class MyDetailsView extends StatefulWidget {
  const MyDetailsView({super.key});

  @override
  State<MyDetailsView> createState() => _MyDetailsViewState();
}

class _MyDetailsViewState extends State<MyDetailsView> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();

  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserService.getUserFromHive();

    firstNameController.text = user.firstName ?? '';
    lastNameController.text = user.lastName ?? '';
    emailController.text = user.email ?? '';
    mobileController.text = user.mobileNumber ?? '';

    areaController.text = user.area ?? '';
    cityController.text = user.city ?? '';
    stateController.text = user.state ?? '';
    pincodeController.text = user.pincode ?? '';
  }

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
                controller: firstNameController,
              ),

              const SizedBox(height: 16),

              /// LAST NAME
              CommonTextField(
                label: "Last Name",
                hint: "Enter last name",
                controller: lastNameController,
              ),

              const SizedBox(height: 16),

              /// EMAIL
              CommonTextField(
                label: "Email",
                hint: "Enter your email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                isReadOnly: true,
              ),

              const SizedBox(height: 16),

              /// MOBILE
              CommonTextField(
                label: "Mobile Number",
                hint: "Enter mobile number",
                controller: mobileController,
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
                controller: areaController,
              ),

              const SizedBox(height: 16),

              /// CITY
              CommonTextField(
                label: "City",
                hint: "Enter city",
                controller: cityController,
              ),

              const SizedBox(height: 16),

              /// STATE
              CommonTextField(
                label: "State",
                hint: "Enter state",
                controller: stateController,
              ),

              const SizedBox(height: 16),

              /// PINCODE
              CommonTextField(
                label: "Pincode",
                hint: "Enter pincode",
                controller: pincodeController,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 30.h),

              /// UPDATE BUTTON
              CommonButton(
                title: "Update",
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  CommonLoader.show();

                  final user = UserService.getUserFromHive();

                  user.firstName = firstNameController.text.trim();
                  user.lastName = lastNameController.text.trim();

                  user.area = areaController.text.trim();
                  user.city = cityController.text.trim();
                  user.state = stateController.text.trim();
                  user.pincode = pincodeController.text.trim();

                  await UserService().updateUser(user);

                  CommonLoader.hide();

                  Get.back(closeOverlays: true);
                  CommonToast.show(
                    "Details updated successfully",
                    type: ToastType.success,
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
