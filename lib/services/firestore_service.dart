import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

/// Abstracts all CRUD operations for Firestore.
/// This service handles the private (user-specific) and public collection paths.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // --- Mandatory Environment Variables ---
  // Note: In a production environment, these would be securely provided.
  // For this project structure, we define the base collection paths as per instruction.
  static const String _appId = 'doctor-booking-app-5c684'; // Placeholder for __app_id
  
  // --- Collection Path Helpers ---

  /// Private collection path for user data: /artifacts/{appId}/users/{userId}/user_data
  CollectionReference<Map<String, dynamic>> _userCollection(String userId) {
    return _db.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('user_data');
  }

  /// Private collection path for appointments: /artifacts/{appId}/users/{userId}/appointments
  CollectionReference<Map<String, dynamic>> _appointmentCollection(String userId) {
    return _db.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('appointments');
  }

  /// Public collection path for doctor list: /artifacts/{appId}/public/data/doctors
  CollectionReference<Map<String, dynamic>> _doctorCollection() {
    return _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('doctors');
  }


  // =========================================================================
  // USER (PATIENT) OPERATIONS
  // =========================================================================

  /// Saves or updates a user's profile data.
  Future<void> saveUserData(UserModel user) async {
    final docRef = _userCollection(user.id).doc('profile');
    return await docRef.set(user.toMap(), SetOptions(merge: true));
  }

  /// Retrieves a user's profile data.
  Future<UserModel?> getUserData(String userId) async {
    final docSnapshot = await _userCollection(userId).doc('profile').get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return UserModel.fromFirestore(docSnapshot);
    }
    return null;
  }
  
  // =========================================================================
  // DOCTOR OPERATIONS (Public Data)
  // =========================================================================

  /// Retrieves a stream of all doctors available in the public collection.
  Stream<List<DoctorModel>> streamAllDoctors() {
    return _doctorCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
    });
  }

  /// Retrieves a single doctor by ID.
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    final doc = await _doctorCollection().doc(doctorId).get();
    if (doc.exists) {
      return DoctorModel.fromFirestore(doc);
    }
    return null;
  }

  // NOTE: For a real app, you would add an admin function here like 'addDoctorData'
  // for setting up the initial public doctor profiles.

  // =========================================================================
  // APPOINTMENT OPERATIONS (Private Data)
  // =========================================================================

  /// Books a new appointment.
  Future<void> bookAppointment(String userId, AppointmentModel appointment) async {
    final docRef = _appointmentCollection(userId).doc(); // Let Firestore auto-generate ID
    await docRef.set(appointment.toMap());
    
    // NOTE: AppointmentModel needs its ID updated if you plan to use it immediately
    // after booking, or you can rely on the stream to update state.
  }
  
  /// Cancels or updates the status of an existing appointment.
  Future<void> updateAppointmentStatus(String userId, String appointmentId, String newStatus) async {
    final docRef = _appointmentCollection(userId).doc(appointmentId);
    await docRef.update({'status': newStatus});
  }

  /// Retrieves a stream of all appointments for the current user.
  Stream<List<AppointmentModel>> streamUserAppointments(String userId) {
    return _appointmentCollection(userId)
        // Sort by date to show upcoming appointments first
        .orderBy('appointmentDateTime', descending: true) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
    });
  }
}