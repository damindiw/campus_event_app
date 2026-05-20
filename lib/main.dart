import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/student/home_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load your hidden configuration file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase by reading variables from the .env file
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
    ),
  );
    
  runApp(const CampusEventApp());
}

class CampusEventApp extends StatelessWidget {
  const CampusEventApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Event Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) return const HomeScreen();
        return const LoginScreen();
      },
    );
  }
}