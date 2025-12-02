import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user profile in the application.
/// This model is used to store and retrieve data from Firebase Firestore
/// for both patients and administrators (if applicable).
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String role; // e.g., 'patient', 'admin'
  final String? phone;
  final String? address;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.role = 'patient',
    this.phone,
    this.address,
  });

  /// Factory method to create a UserModel instance from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null.");
    }
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? 'User',
      profileImageUrl: data['profileImageUrl'],
      role: data['role'] ?? 'patient',
      phone: data['phone'],
      address: data['address'],
    );
  }

  /// Converts the UserModel instance into a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'phone': phone,
      'address': address,
      // Note: 'id' is used as the document ID in Firestore and not stored inside the map
    };
  }

  /// Creates a copy of the model with optional new values.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? role,
    String? phone,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}