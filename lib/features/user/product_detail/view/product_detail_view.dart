import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/common_widgets/common_button.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int quantity = 1;

  final List<Map<String, dynamic>> weightOptions = [
    {"label": "250 gm", "multiplier": 0.25},
    {"label": "500 gm", "multiplier": 0.5},
    {"label": "1 Kg", "multiplier": 1.0},
  ];

  int selectedWeightIndex = 2; // default 1 Kg
  double basePricePerKg = 4.99;

  final List<String> imageList = [
    "assets/png/apple_image.png",
    "assets/png/apple_image.png",
    "assets/png/apple_image.png",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 413.h,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xffF2F3F2),

              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  /// 🔙 Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Get.back();
                          },
                          child: SvgPicture.asset("assets/svg/back_arrow_icon.svg")),
                      SizedBox()
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🖼 Image Slider
                  SizedBox(
                    height: 220.h,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imageList.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.asset(
                          imageList[index],
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// ⚪ Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      imageList.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin:  EdgeInsets.symmetric(horizontal: 3.h),
                        height: 5.h,
                        width: _currentIndex == index ? 15.w : 5.w,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.primary
                              : Color(0xffB3B3B3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h,),
                  /// TITLE + FAVORITE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Naturel Red Apple",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.favorite_border),
                    ],
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "1kg, Price",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  /// WEIGHT CHIPS
                  Wrap(
                    spacing: 10,
                    children: List.generate(weightOptions.length, (index) {
                      final isSelected = selectedWeightIndex == index;
                      return ChoiceChip(
                        label: Text(weightOptions[index]['label']),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedWeightIndex = index;
                            quantity = 1; // reset quantity on change (optional)
                          });
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  /// QUANTITY + PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                            child: _qtyButton(Icons.remove),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                quantity.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            child: _qtyButton(Icons.add, isAdd: true),
                          ),
                        ],
                      ),
                      Text(
                        "₹${(basePricePerKg * weightOptions[selectedWeightIndex]['multiplier'] * quantity).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),


                  const Divider(height: 32),

                  /// PRODUCT DETAIL
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.all(0),
                    shape: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                    title: const Text(
                      "Product Detail",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          "Apples are nutritious. Apples may be good for weight loss. "
                              "Apples may be good for your heart. As part of a healthy and varied diet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  const Divider(),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Text(
                        "Review",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(
                          5,
                              (_) => const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w,),
                      Icon(Icons.keyboard_arrow_right_outlined)
                    ],
                  ),
                  SizedBox(height: 25,),


                 CommonButton(title: "Add To Basket", onTap: () {

                 },),


                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _qtyButton(IconData icon, {bool isAdd = false}) {
    return Icon(
      icon,
      color: isAdd ? Colors.green : Colors.grey.shade600,
    );
  }

}
