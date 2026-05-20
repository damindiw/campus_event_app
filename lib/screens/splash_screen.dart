import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ==================== YOUR LOGO PLACEHOLDER ====================
                // OPTION A: If you have an image file ready, uncomment the line below:
                // Image.asset('assets/logo.png', height: 120, width: 120),
                
                // OPTION B: A clean, material-styled brand icon placeholder
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    size: 80,
                    color: Colors.indigo,
                  ),
                ),
                // ==============================================================
                
                const SizedBox(height: 24),
                const Text(
                  'Campus Event Manager',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Select your role to continue',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 30),
                
                // Student Selection Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 55),
                    backgroundColor: Colors.indigo,
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(role: 'student'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.school, color: Colors.white),
                  label: const Text('Student Portal', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                
                // Admin Selection Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(250, 55),
                    side: const BorderSide(color: Colors.indigo, width: 2),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(role: 'admin'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.indigo),
                  label: const Text('Admin Portal', style: TextStyle(fontSize: 18, color: Colors.indigo)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}