import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _register() async {
  if (_formKey.currentState!.validate()) {
    try {
      await AuthService().registerWithEmail(
        _name.text.trim(), 
        _email.text.trim(), 
        _password.text.trim()
      );
      // This if statement ensures the screen is still active before navigating
      if (mounted) {
        Navigator.pop(context);
      }
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
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: "Name"), validator: (v)=>v!.isEmpty?"Required":null),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email"), validator: (v)=>v!.isEmpty?"Required":null),
              TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: "Password"), validator: (v)=>v!.isEmpty?"Required":null),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: const Text("Create Account")),
            ],
          ),
        ),
      ),
    );
  }
}