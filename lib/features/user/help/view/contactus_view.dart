import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';

class ContactusView extends StatelessWidget {
  const ContactusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Contact Us"),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Office Address",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text("Ahmedabad, Gujarat, India"),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text("contact@groceryapp.com"),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone"),
              subtitle: Text("+91 99999 88888"),
            ),
          ],
        ),
      ),
    );
  }
}
