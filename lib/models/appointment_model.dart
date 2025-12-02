import 'package:cloud_firestore/cloud_firestore.dart';

/// Defines the structure for a patient's booked appointment.
class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime appointmentDateTime;
  final double consultationFee;
  final String status; // e.g., 'Pending', 'Confirmed', 'Completed', 'Cancelled'
  final String reason;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.appointmentDateTime,
    required this.consultationFee,
    this.status = 'Pending',
    required this.reason,
  });

  /// Factory method to create an AppointmentModel instance from a Firestore document snapshot.
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data for Appointment is null.");
    }
    
    // Safely parse the timestamp to a DateTime object
    final timestamp = data['appointmentDateTime'] as Timestamp?;

    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'Unknown Doctor',
      doctorSpecialty: data['doctorSpecialty'] ?? 'N/A',
      appointmentDateTime: timestamp?.toDate() ?? DateTime.now(),
      consultationFee: (data['consultationFee'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'Pending',
      reason: data['reason'] ?? 'Routine checkup',
    );
  }

  /// Converts the AppointmentModel instance into a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'appointmentDateTime': Timestamp.fromDate(appointmentDateTime), // Save as Firestore Timestamp
      'consultationFee': consultationFee,
      'status': status,
      'reason': reason,
      // Note: 'id' is used as the document ID in Firestore
    };
  }
  
  /// Creates a copy of the model with optional new values.
  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    DateTime? appointmentDateTime,
    double? consultationFee,
    String? status,
    String? reason,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      consultationFee: consultationFee ?? this.consultationFee,
      status: status ?? this.status,
      reason: reason ?? this.reason,
    );
  }
}