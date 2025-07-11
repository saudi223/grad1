import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String userId;
  final String email;
  final String name;
  final String role; // 'patient' or 'doctor'
  final DateTime createdAt;
  final String? profileImage;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.profileImage,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImage': profileImage,
    };
  }
}