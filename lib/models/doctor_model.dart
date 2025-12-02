import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a Doctor profile in the application.
/// This model stores public data used for searching, viewing details, and booking.
class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String? hospital;
  final String? profileImageUrl;
  final String bio;
  final double rating;
  final int reviewsCount;
  final double consultationFee;
  // Availability is simplified here; in a real app, this would be a complex structure or a service call
  final List<String> availableDays; // e.g., ['Monday', 'Wednesday', 'Friday']
  final List<String> availableTimeSlots; // e.g., ['09:00', '10:00', '11:00']

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.hospital,
    this.profileImageUrl,
    required this.bio,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.consultationFee,
    this.availableDays = const [],
    this.availableTimeSlots = const [],
  });

  /// Factory method to create a DoctorModel instance from a Firestore document snapshot.
  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data for Doctor is null.");
    }
    
    // Helper to safely cast list types
    List<String> getStrings(String key) {
      return (data[key] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    }

    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? 'Dr. Unknown',
      specialty: data['specialty'] ?? 'General Practice',
      hospital: data['hospital'],
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'] ?? 'No biography available.',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: data['reviewsCount'] ?? 0,
      consultationFee: (data['consultationFee'] as num?)?.toDouble() ?? 0.0,
      availableDays: getStrings('availableDays'),
      availableTimeSlots: getStrings('availableTimeSlots'),
    );
  }

  /// Converts the DoctorModel instance into a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'hospital': hospital,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'consultationFee': consultationFee,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
    };
  }

  /// Creates a copy of the model with optional new values.
  DoctorModel copyWith({
    String? id,
    String? name,
    String? specialty,
    String? hospital,
    String? profileImageUrl,
    String? bio,
    double? rating,
    int? reviewsCount,
    double? consultationFee,
    List<String>? availableDays,
    List<String>? availableTimeSlots,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      hospital: hospital ?? this.hospital,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      consultationFee: consultationFee ?? this.consultationFee,
      availableDays: availableDays ?? this.availableDays,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
    );
  }
}