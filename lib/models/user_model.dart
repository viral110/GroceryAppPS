import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String storeId;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? gstNumber;
  String? mobileNumber;
  double? credit; // ✅ Changed from int to double
  double? usedCredits; // ✅ Changed from int to double
  double? remainingCredits; // ✅ Changed from int to double
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
  String? businessName;

  UserModel({
    this.uid = "",
    this.storeId = "",
    this.firstName,
    this.lastName,
    this.email,
    this.gstNumber,
    this.mobileNumber,
    this.credit,
    this.password,
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
    this.isEnable = false,
    this.businessName,
  });

  /// Convert Firestore doc to model
  factory UserModel.fromJson(Map map, {String? id}) {
    return UserModel(
      uid: id ?? '',
      storeId: map['store_id'] ?? "",
      firstName: map['first_name'],
      lastName: map['last_name'],
      password: map['password'],
      businessName: map['businessName'],
      email: map['email'],
      gstNumber: map['gst_number'],
      mobileNumber: map['mobile_number'],
      area: map['area'],
      city: map['city'],
      credit: (map['credit'] as num?)?.toDouble(), // ✅ Convert to double
      usedCredits: (map['used_credits'] as num?)
          ?.toDouble(), // ✅ Convert to double
      remainingCredits: (map['remaining_credits'] as num?)
          ?.toDouble(), // ✅ Convert to double
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
      'password': password,
      'businessName': businessName,
      'store_id': storeId ?? "",
      'email': email,
      'gst_number': gstNumber,
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
      'isEnable': isEnable,
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
