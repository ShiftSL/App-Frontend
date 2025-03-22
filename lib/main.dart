import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_sl/features/core/schedule/schedule_screen_v2.dart';
import 'package:shift_sl/screens/sign_in_screen.dart';
import 'package:shift_sl/screens/sign_up_screen.dart';
import 'package:shift_sl/screens/main_scaffold.dart';
import 'package:shift_sl/screens/notification_screen.dart';
// import 'package:shift_sl/screens/schedule_screen.dart';
import 'package:shift_sl/screens/swaps_screen.dart';
import 'package:shift_sl/screens/apply_for_leave_screen.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/screens/profile_screen.dart';
import 'package:shift_sl/features/authentication/screens/onboarding.dart';
import 'package:shift_sl/utils/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/signIn', page: () => const SignInScreen()),
        GetPage(name: '/signUp', page: () => const SignUpScreen()),
        GetPage(name: '/home', page: () => const MainScaffold()),
        GetPage(name: '/notifications', page: () => const NotificationScreen()),
        GetPage(name: '/schedule', page: () => ShiftManagementScreen()),
        GetPage(name: '/swaps', page: () => const SwapsScreen()),
        GetPage(
            name: '/applyForLeave', page: () => const ApplyForLeaveScreen()),
        GetPage(name: '/editProfile', page: () => const EditProfileScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
      ],
    );
  }
}

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

    if (sessionExpiry != null &&
        DateTime.parse(sessionExpiry).isAfter(DateTime.now())) {
      Get.offAllNamed('/home');
    } else {
      if (!hasOnboarded) {
        Get.offAllNamed('/onboarding');
      } else {
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
