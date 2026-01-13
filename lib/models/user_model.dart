import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  String uid;
  String storeId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNumber;
  int? credit;
  int? usedCredits;
  int? remainingCredits;
  // Address
  String? area;
  String? city;
  String? state;
  String? pincode;
  DateTime? createdAt;
  DateTime? updateAt;
  String? fcmToken;
  bool isNotification;
  bool isAdmin;
  bool isEnable;


  UserModel({
    this.uid = "",
    this.storeId = "",
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNumber,
    this.credit,
    this.usedCredits,
    this.remainingCredits,
    this.area,
    this.city,
    this.state,
    this.pincode,
    this.createdAt,
    this.fcmToken,
    this.updateAt,
    this.isNotification = true,
    this.isAdmin = false,
    this.isEnable= false,
  });

  /// Convert Firestore doc to model
  factory UserModel.fromJson(Map map, {String? id}) {
    return UserModel(
      uid: id ?? '',
      storeId: map['store_id']??"",
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: map['email'],
      mobileNumber: map['mobile_number'],
      area: map['area'],
      city: map['city'],
      credit: map['credit'],
      usedCredits: map['used_credits'],
      remainingCredits: map['remaining_credits'],
      state: map['state'],
      pincode: map['pincode'],
      createdAt: checkObjectForDateTime(map['created_at']),
      updateAt: checkObjectForDateTime(map['update_at']),
      fcmToken: map['fcm_token'],
      isNotification: map['isNotification'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      isEnable: map['isEnable'] ?? true,
    );
  }

  /// Convert model to Firestore map
  Map<String, dynamic> toJson({bool setInHive = false}) {
    return {
      if (setInHive) "uid": uid,
      'first_name': firstName,
      'last_name': lastName,
     'store_id': storeId ??"",
      'email': email,
      'mobile_number': mobileNumber,
      'credit': credit,
      'used_credits': usedCredits,
      'remaining_credits': remainingCredits,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'created_at': createdAt?.toIso8601String(),
      'update_at': updateAt?.toIso8601String(),
      'fcm_token': fcmToken,
      'isNotification': isNotification,
      'isAdmin': isAdmin,
      'isEnable':isEnable,
    };
  }

  static DateTime? checkObjectForDateTime(Object? obj) {
    if (obj != null) {
      if (obj is String) {
        return DateTime.tryParse(obj.toString());
      } else if (obj is Timestamp) {
        return obj.toDate();
      } else if (obj is DateTime) {
        return obj;
      }
    }
    return null;
  }
}
