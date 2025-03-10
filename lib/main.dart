import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shift_sl/features/authentication/screens/onboarding.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/screens/profile_screen.dart';
import 'utils/theme/theme.dart'; // This file should define shiftSlLightTheme.
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/notification_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/swaps_screen.dart';
import 'screens/apply_for_leave_screen.dart';

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
      theme: shiftSlTheme, // Only using the light theme.
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/home': (context) => const MainScaffold(),
        '/notifications': (context) => const NotificationScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/swaps': (context) => const SwapsScreen(),
        '/applyForLeave': (context) => const ApplyForLeaveScreen(),
        '/editProfile': (context) => const EditProfileScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
