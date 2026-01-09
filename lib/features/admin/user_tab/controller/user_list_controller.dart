import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_groceries_app/models/user_model.dart';
import 'package:online_groceries_app/utils/app_constant.dart';

class UserListController extends GetxController {
  final searchQuery = "".obs;

  Stream<List<UserModel>> getUsers() {
    return FirebaseFirestore.instance
        .collection(AppConstantStrings.userCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data(),id: doc.id );
      }).toList();
    });
  }

  List<UserModel> filterUsers(List<UserModel> users) {
    if (searchQuery.value.isEmpty) return users;

    return users.where((user) {
      final query = searchQuery.value.toLowerCase();

      return (user.firstName!.toLowerCase().contains(query)) ||
          (user.lastName!.toLowerCase().contains(query)) ||
          (user.email?.toLowerCase().contains(query) ?? false) ||
          (user.mobileNumber?.contains(query) ?? false);
    }).toList();
  }
}
