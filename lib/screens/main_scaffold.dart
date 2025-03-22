import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/features/core/schedule/schedule_screen_v2.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'home_screen.dart';
// import 'schedule_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // List of screens for each tab.
  final List<Widget> _screens = [
    HomeScreen(), // Your home screen widget.
    ShiftManagementScreen(), // Your schedule screen widget.
    const NotificationScreen(), // Your notification screen widget.
    const ProfileScreen(), // Your profile screen widget.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: ShiftslColors.primaryColor,
              unselectedItemColor: const Color(0xFF818181),
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed, // use fixed for 4+ items
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home),
                  activeIcon:
                      Icon(Iconsax.home_15, color: ShiftslColors.primaryColor),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.calendar_2),
                  activeIcon: Icon(Iconsax.calendar_25,
                      color: ShiftslColors.primaryColor),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.notification_bing4),
                  activeIcon: Icon(Iconsax.notification_bing5,
                      color: ShiftslColors.primaryColor),
                  label: 'Notification',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.menu_board4),
                  activeIcon: Icon(Iconsax.menu_board5,
                      color: ShiftslColors.primaryColor),
                  label: 'Menu',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
