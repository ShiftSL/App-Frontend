import 'package:flutter/material.dart';
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

  void _register() async {
    final success = true;
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please sign in.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final verticalSpacing = screenWidth * 0.1;
    final logoWidth = screenWidth * 0.8;
    final padding = screenWidth * 0.05;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            SizedBox(height: verticalSpacing),
            ShiftSlLogo(width: logoWidth, height: logoWidth * (350 / 400)),
            SizedBox(height: verticalSpacing),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: padding),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: padding),
            TextField(
              controller: _hospitalController,
              decoration: const InputDecoration(
                labelText: 'Hospital/Institution',
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),
            SizedBox(height: padding),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: padding * 1.5),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Already have an account? Sign In',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
