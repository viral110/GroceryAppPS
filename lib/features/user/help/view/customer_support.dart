import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';

class CustomerSupport extends StatelessWidget {
  const CustomerSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Customer Support"),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: const [
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Support Email"),
              subtitle: Text("support@groceryapp.com"),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("Support Phone"),
              subtitle: Text("+91 98765 43210"),
            ),
          ],
        ),
      ),
    );
  }
}
