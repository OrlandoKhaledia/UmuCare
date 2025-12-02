import 'dart:async';
import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../services/firestore_service.dart';

/// Manages the list of available doctors and related search/filter logic.
class DoctorProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<DoctorModel> _allDoctors = [];
  List<DoctorModel> _filteredDoctors = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Stream subscription to maintain a real-time connection to Firestore
  StreamSubscription<List<DoctorModel>>? _doctorsSubscription;

  List<DoctorModel> get allDoctors => _allDoctors;
  List<DoctorModel> get filteredDoctors => _filteredDoctors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DoctorProvider() {
    _subscribeToDoctors();
  }

  /// Subscribes to the Firestore stream to get all doctor data in real-time.
  void _subscribeToDoctors() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _doctorsSubscription?.cancel(); // Cancel previous subscription if any
    
    try {
      _doctorsSubscription = _firestoreService.streamAllDoctors().listen(
        (doctorsList) {
          _allDoctors = doctorsList;
          _filteredDoctors = doctorsList; // Initialize filtered list with all doctors
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load doctors: $error';
          _isLoading = false;
          print('Doctor Stream Error: $error');
          notifyListeners();
        },
        onDone: () {
          print('Doctor Stream closed.');
        }
      );
    } catch (e) {
      _errorMessage = 'Initialization error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters the doctors list based on a search query.
  void filterDoctors(String query) {
    if (query.isEmpty) {
      _filteredDoctors = _allDoctors;
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _filteredDoctors = _allDoctors.where((doctor) {
        // Search by name or specialty
        return doctor.name.toLowerCase().contains(lowerCaseQuery) ||
               doctor.specialty.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }
    notifyListeners();
  }
  
  /// Utility function to find a doctor by ID from the locally cached list.
  DoctorModel? getDoctorById(String doctorId) {
    return _allDoctors.firstWhere((doctor) => doctor.id == doctorId, 
      orElse: () => throw Exception('Doctor with ID $doctorId not found.'));
  }

  @override
  void dispose() {
    _doctorsSubscription?.cancel();
    super.dispose();
  }
}