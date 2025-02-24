import 'package:flutter/material.dart';
import '../widgets/shift_sl_logo.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signIn() async {
    final success = true;
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in failed!')),
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
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
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
              onPressed: _signIn,
              child: const Text('Sign In', style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signUp'),
              child: const Text(
                'Don’t have an account? Sign Up',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
