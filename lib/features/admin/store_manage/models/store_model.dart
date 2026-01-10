class StoreModel {
  final String id;
  final String name;
  final String address;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
  });

  factory StoreModel.fromJson(String id, Map<String, dynamic> json) {
    return StoreModel(
      id: id,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'createdAt': DateTime.now(),
    };
  }
}
