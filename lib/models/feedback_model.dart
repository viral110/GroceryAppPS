import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String uid;
  final int rating;
  final String message;
  final Timestamp createdAt;

  FeedbackModel({
    required this.uid,
    required this.rating,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'rating': rating,
      'message': message,
      'created_at': createdAt,
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      uid: json['uid'] ?? '',
      rating: json['rating'] ?? 0,
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? Timestamp.now(),
    );
  }
}
