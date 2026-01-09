import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';

class FaqsView extends StatelessWidget {
  const FaqsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "FAQs"),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: const [
          ExpansionTile(
            title: Text("How to place an order?"),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "You can place an order by adding products to your cart and checking out.",
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How to cancel an order?"),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Go to My Orders and cancel before dispatch.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
