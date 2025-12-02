import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// --- Imports for Models ---
// NOTE: These files (like doctor_model.dart) must be created in the lib/models/ directory next.
import 'models/doctor_model.dart'; 

// --- Imports for Providers ---
// NOTE: These files must be created in the lib/providers/ directory next.
import 'providers/auth_provider.dart';
import 'providers/doctor_provider.dart';
import 'providers/appointment_provider.dart';

// --- Imports for Screens ---
// NOTE: These files must be created in the lib/pages/ directory next.
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/doctor_detail_screen.dart';
import 'screens/appointments/booking_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'screens/appointments/appointments_screen.dart';


// --- Global Constants and Styling ---

class AppColors {
  static const Color primary = Color(0xFF1ABC9C); // Teal/Turquoise
  static const Color secondary = Color(0xFF34495E); // Dark Slate
  static const Color background = Color(0xFFF5F7FA);
}

// --- Main Function and Firebase Initialization ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase Core services
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
    // In a production app, show an error screen here (e.g., using a simple widget)
  }

  runApp(const DoctorBookingApp());
}

// --- Application Root and MultiProvider Setup ---

class DoctorBookingApp extends StatelessWidget {
  const DoctorBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. AuthProvider must be at the top level
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // 2. DoctorProvider fetches all public doctor data
        ChangeNotifierProvider(create: (_) => DoctorProvider()),

        // 3. AppointmentProvider depends on AuthProvider for the userId
        // Note: ProxyProvider ensures AppointmentProvider is rebuilt/updated when AuthProvider changes
        ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>(
          // Initial creation
          create: (context) => AppointmentProvider(context.read<AuthProvider>()),
          // Update method ensures AppointmentProvider reacts to AuthProvider changes
          update: (context, auth, appointment) => AppointmentProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Doctor Booking App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Primary color definitions
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          
          // Scaffold background
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          fontFamily: 'Inter',

          // Common input decoration theme for consistency
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          ),
          
          // Button theme for a professional look
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        // --- Named Routes (Routes without arguments) ---
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/appointments': (context) => const AppointmentsScreen(), 
          '/splash': (context) => const SplashScreen(),
          
          
          
        },
        
        // --- Argument-Dependent Routes (onGenerateRoute) ---
        onGenerateRoute: (settings) {
          final arguments = settings.arguments;

          switch (settings.name) {
            case '/doctor-detail':
              if (arguments is DoctorModel) {
                return MaterialPageRoute(
                  builder: (_) => DoctorDetailScreen(doctor: arguments),
                );
              }
              // Fallback if no valid argument is provided
              return MaterialPageRoute(builder: (_) => const HomeScreen()); 

            case '/booking':
              if (arguments is DoctorModel) {
                return MaterialPageRoute(
                  builder: (_) => BookingScreen(doctor: arguments),
                );
              }
              // Fallback if no valid argument is provided
              return MaterialPageRoute(builder: (_) => const HomeScreen());
              
            default:
              // Fallback to AuthWrapper for any unknown named routes
              return MaterialPageRoute(builder: (_) => const AuthWrapper());
          }
        },
        
        // The initial widget is the AuthWrapper
        home: const AuthWrapper(),
      ),
    );
  }
}

// --- Authentication State Wrapper for Routing ---

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the authentication state from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Show Splash Screen while the auth state is being determined
    if (authProvider.isLoading) {
      return const SplashScreen();
    }

    // 2. Check if the user is authenticated (user is not null)
    if (authProvider.user != null) {
      // User is logged in, navigate to the main application area
      return const HomeScreen();
    } else {
      // User is logged out, navigate to the Login screen
      return const LoginScreen();
    }
  }
}  