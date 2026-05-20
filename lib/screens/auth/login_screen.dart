import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
  if (_formKey.currentState!.validate()) {
    try {
      await AuthService().loginWithEmail(
        _email.text.trim(), 
        _password.text.trim()
      );
      // No extra navigation line is needed here because AuthGate in main.dart 
      // automatically detects the login state change and switches screens!
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
        );
      }
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email"), validator: (v)=>v!.isEmpty?"Required":null),
              TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: "Password"), validator: (v)=>v!.isEmpty?"Required":null),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text("Login")),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text("Register instead"))
            ],
          ),
        ),
      ),
    );
  }
}