import 'package:flutter/material.dart';
import '../../main.dart'; // To access AppColors

/// The initial screen shown while the application is determining
/// the user's authentication state (logged in or logged out).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Use the background color for a clean look
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for the App Logo/Icon
            Icon(
              Icons.healing_outlined,
              size: 100,
              color: AppColors.primary,
            ),
            SizedBox(height: 20),
            
            // App Title
            Text(
              'DoctorConnect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: 40),
            
            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 10),
            
            // Status Text
            Text(
              'Loading application...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}