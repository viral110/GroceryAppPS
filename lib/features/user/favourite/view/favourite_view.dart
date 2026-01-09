import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_app_bar.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/features/user/product_detail/view/product_detail_view.dart';

class FavouriteView extends StatelessWidget {
  const FavouriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: "Favourite",showBack: false,),

      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _favItems.length,
              separatorBuilder: (_, __) => const Divider(height: 38,),
              itemBuilder: (context, index) {
                final item = _favItems[index];
                return GestureDetector(
                  onTap: (){
                    Get.to(()=>ProductDetailView());
                  },
                  child: Row(
                    children: [
                      Image.asset(item.image, height: 45),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(item.subtitle,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        item.price,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: CommonButton(title: "Add All To Cart", onTap: () {

            },),
          )
        ],
      ),
    );
  }
}

/// MODEL
class FavouriteItem {
  final String title;
  final String subtitle;
  final String price;
  final String image;

  FavouriteItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.image,
  });
}

/// DATA
final List<FavouriteItem> _favItems = [
  FavouriteItem(
    title: "Sprite Can",
    subtitle: "325ml, Price",
    price: "\$1.50",
    image: "assets/png/category/oil.png",
  ),
  FavouriteItem(
    title: "Diet Coke",
    subtitle: "355ml, Price",
    price: "\$1.99",
    image: "assets/png/category/oil.png",
  ),
  FavouriteItem(
    title: "Apple & Grape Juice",
    subtitle: "2L, Price",
    price: "\$15.50",
    image: "assets/png/category/oil.png",
  ),
  FavouriteItem(
    title: "Coca Cola Can",
    subtitle: "325ml, Price",
    price: "\$4.99",
    image: "assets/png/category/oil.png",
  ),
  FavouriteItem(
    title: "Pepsi Can",
    subtitle: "330ml, Price",
    price: "\$4.99",
    image: "assets/png/category/oil.png",
  ),
];
