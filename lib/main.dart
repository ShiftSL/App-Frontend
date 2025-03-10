import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_sl/features/authentication/screens/onboarding.dart';
import 'package:shift_sl/screens/sign_in_screen.dart';
import 'package:shift_sl/screens/sign_up_screen.dart';
import 'package:shift_sl/screens/main_scaffold.dart';
import 'package:shift_sl/screens/notification_screen.dart';
import 'package:shift_sl/screens/schedule_screen.dart';
import 'package:shift_sl/screens/swaps_screen.dart';
import 'package:shift_sl/screens/apply_for_leave_screen.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/screens/profile_screen.dart';
import 'package:shift_sl/utils/theme/theme.dart'; // Contains shiftSlTheme

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShiftSlApp());
}

class ShiftSlApp extends StatelessWidget {
  const ShiftSlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShiftSL',
      theme: shiftSlTheme,
      // Start with the splash screen to decide navigation based on session and onboarding status.
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/signIn', page: () => const SignInScreen()),
        GetPage(name: '/signUp', page: () => const SignUpScreen()),
        GetPage(name: '/home', page: () => const MainScaffold()),
        GetPage(name: '/notifications', page: () => const NotificationScreen()),
        GetPage(name: '/schedule', page: () => const ScheduleScreen()),
        GetPage(name: '/swaps', page: () => const SwapsScreen()),
        GetPage(name: '/applyForLeave', page: () => const ApplyForLeaveSheet()),
        GetPage(name: '/editProfile', page: () => const EditProfileScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
      ],
    );
  }
}

/// The SplashScreen widget is used to decide which screen to navigate to:
/// - If a valid session exists (i.e. within 30 days), it navigates to the home screen.
/// - If there is no valid session and the user hasn't onboarded, it navigates to the onboarding screen.
/// - Otherwise, it goes to the sign-in screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _decideNavigation();
  }

  Future<void> _decideNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionExpiry = prefs.getString('sessionExpiry');
    final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;

    // Check if the session is still valid
    if (sessionExpiry != null &&
        DateTime.parse(sessionExpiry).isAfter(DateTime.now())) {
      // Session is valid, navigate directly to the home screen.
      Get.offAllNamed('/home');
    } else {
      // Session expired or doesn't exist; check the onboarding status.
      if (!hasOnboarded) {
        // User hasn't onboarded, navigate to the onboarding screen.
        Get.offAllNamed('/onboarding');
      } else {
        // Otherwise, prompt the user to sign in.
        Get.offAllNamed('/signIn');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
