import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/shift_sl_logo.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionExpiry = prefs.getString('sessionExpiry');
    if (sessionExpiry != null) {
      final expiryDate = DateTime.parse(sessionExpiry);
      if (expiryDate.isAfter(DateTime.now())) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        prefs.remove('sessionExpiry');
      }
    }
  }

  Future<void> _startPhoneAuth() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _onSignInSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isOtpSent = true;
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (_verificationId == null || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP or verification ID')),
      );
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _onSignInSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _onSignInSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = DateTime.now().add(const Duration(days: 30));
    await prefs.setString('sessionExpiry', expiryDate.toIso8601String());

    // Check if onboarding has been shown
    final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
    if (!hasOnboarded) {
      await prefs.setBool('hasOnboarded', true);
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// **Temporary Bypass Function**
  void _bypassAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = DateTime.now().add(const Duration(days: 90));
    await prefs.setString('sessionExpiry', expiryDate.toIso8601String());

    Navigator.pushReplacementNamed(context, '/home');
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
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            if (_isOtpSent) ...[
              SizedBox(height: padding),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
            SizedBox(height: padding * 1.5),
            ElevatedButton(
              onPressed: _isOtpSent ? _verifyOtp : _startPhoneAuth,
              child: Text(_isOtpSent ? 'Verify OTP' : 'Send OTP',
                  style: const TextStyle(fontSize: 16)),
            ),
            SizedBox(height: padding),

            /// **Temporary Bypass Button**
            TextButton(
              onPressed: _bypassAuthentication,
              child: const Text(
                'Skip Authentication (Temporary)',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
