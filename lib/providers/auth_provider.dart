import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Manages the user's authentication state and profile data throughout the application.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _subscribeToAuthState();
  }

  /// Listens to the Firebase Auth state stream to automatically update the user state.
  void _subscribeToAuthState() {
    _authService.user.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        // User is logged out
        _user = null;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      } else {
        // User is logged in, fetch the corresponding Firestore profile
        try {
          final userModel = await _firestoreService.getUserData(firebaseUser.uid);
          _user = userModel;
        } catch (e) {
          // Handle case where Firestore data retrieval fails
          print('Error fetching user data for UID ${firebaseUser.uid}: $e');
          _user = null; // Treat as logged out or failed state
        }
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }
    });
  }

  // =========================================================================
  // AUTHENTICATION OPERATIONS
  // =========================================================================

  /// Handles user registration.
  Future<void> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      _user = await _authService.signUp(email, password, name);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Handles user login.
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.signIn(email, password);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Handles user logout.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      // Auth listener will handle setting _user to null
    } catch (e) {
      _errorMessage = 'Error during sign out.';
      print(e);
    } finally {
      _setLoading(false);
    }
  }
  
  // =========================================================================
  // UTILITY METHODS
  // =========================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}