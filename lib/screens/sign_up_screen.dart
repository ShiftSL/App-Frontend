import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/shift_sl_logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final hospital = _hospitalController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || hospital.isEmpty) {
      _showMessage('Please fill in all fields');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showMessage('Account created! Please sign in.');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showMessage('Registration failed: ${e.message}');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ShiftSlLogo(width: 200, height: 175),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _hospitalController,
              decoration: const InputDecoration(labelText: 'Hospital/Institution'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Already have an account? Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
