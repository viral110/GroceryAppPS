class AboutModel {
  final String appName;
  final String description;
  final String version;

  AboutModel({
    required this.appName,
    required this.description,
    required this.version,
  });

  factory AboutModel.fromMap(Map<String, dynamic> map) {
    return AboutModel(
      appName: map['app_name'] ?? '',
      description: map['description'] ?? '',
      version: map['version'] ?? '',
    );
  }
}
