import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

/// Service class to handle all Firebase Authentication operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Exposes the stream of the current Firebase User.
  Stream<User?> get user => _auth.authStateChanges();

  // =========================================================================
  // SIGN UP / REGISTRATION
  // =========================================================================

  /// Signs up a new user with email and password, and creates a Firestore profile.
  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Create a new UserModel instance
        final newUser = UserModel(
          id: user.uid,
          email: user.email!,
          name: name,
          role: 'patient', // Default role for new users
        );

        // Save the profile data to Firestore
        await _firestoreService.saveUserData(newUser);
        
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Throw a specific error message for UI consumption
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unknown error occurred during registration.');
    }
  }

  // =========================================================================
  // SIGN IN / LOGIN
  // =========================================================================

  /// Signs in an existing user with email and password.
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Retrieve the full UserModel from Firestore
        return await _firestoreService.getUserData(user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('An unknown error occurred during sign-in.');
    }
  }

  // =========================================================================
  // SIGN OUT / LOGOUT
  // =========================================================================

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // =========================================================================
  // ERROR HANDLING
  // =========================================================================

  /// Maps FirebaseAuthException codes to user-friendly messages.
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}