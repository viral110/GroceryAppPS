class SupportModel {
  final String email;
  final String phone;

  SupportModel({required this.email, required this.phone});

  factory SupportModel.fromMap(Map<String, dynamic> map) {
    return SupportModel(
      email: map['support_email'] ?? '',
      phone: map['support_phone'] ?? '',
    );
  }
}
