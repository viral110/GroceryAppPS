import 'package:get/get.dart';
import 'package:online_groceries_app/features/user/my_cart/view/my_cart_view.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var quantities = <int>[].obs;
  RxString selectedPaymentMethod = "Select Method".obs;
  RxDouble discount = 0.0.obs;
  @override
  void onInit() {
    super.onInit();
    cartItems.assignAll(_cartItems);
    quantities.assignAll(List.generate(_cartItems.length, (_) => 1));
  }
  final List<CartItem> _cartItems = [
    CartItem(
      title: "Bell Pepper Red",
      subtitle: "1kg, Price",
      price: "₹4.99",
      image: "assets/png/category/bakery.png",
    ),
    CartItem(
      title: "Egg Chicken Red",
      subtitle: "4pcs, Price",
      price: "₹1.99",
      image: "assets/png/category/bakery.png",
    ),
    CartItem(
      title: "Organic Bananas",
      subtitle: "12kg, Price",
      price: "₹3.00",
      image: "assets/png/category/bakery.png",
    ),
    CartItem(
      title: "Ginger",
      subtitle: "250gm, Price",
      price: "₹2.99",
      image: "assets/png/category/bakery.png",
    ),
  ];

  void increment(int index) {
    quantities[index]++;
  }

  void decrement(int index) {
    if (quantities[index] > 1) {
      quantities[index]--;
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
    quantities.removeAt(index);
  }
}