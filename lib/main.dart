import 'package:fintechui/presentation/screens/onboarding/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'core/services/realtime_balance_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "SF Pro Text",
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: SplashScreen(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded successfully");
  } catch (e) {
    print("Warning: Could not load .env file: $e");
    print("Make sure to create a .env file with your Paystack API keys");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
    
    // Initialize real-time balance service when user is authenticated
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          final balanceService = RealtimeBalanceService();
          await balanceService.initializeRealtimeUpdates();
          print("Real-time balance service initialized for user: ${user.email}");
        } catch (e) {
          print("Error initializing real-time balance service: $e");
        }
      }
    });
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

