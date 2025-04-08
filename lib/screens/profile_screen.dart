import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../features/core/schedule/schedule_screen_v2.dart';
import '../models/user.dart';
import 'edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'leave_requests_screen.dart';
import 'leave_report_screen.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Loads the profile data from local cache and then from the API.
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() {
        _errorMessage = "User not signed in.";
        _isLoading = false;
      });
      return;
    }

    final cachedUserData = prefs.getString('doctorData');
    if (cachedUserData != null) {
      try {
        final decoded = json.decode(cachedUserData);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _user = UserModel.fromJson(decoded);
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error decoding cached profile: $e");
      }
    }
    _fetchProfileFromAPI(firebaseUser.uid);
  }

  /// Fetches latest profile data.
  Future<void> _fetchProfileFromAPI(String firebaseUid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      setState(() {
        _errorMessage = "No auth token found";
        _isLoading = false;
      });
      return;
    }
    final url = Uri.parse("https://kings.backend.shiftsl.com/api/user/firebase/$firebaseUid");
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final user = UserModel.fromJson(jsonData);
        await prefs.setString('doctorData', json.encode(user.toJson()));
        if (mounted) {
          setState(() {
            _user = user;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to load profile data: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching profile data: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!)));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _user!.profileImageUrl != null
                  ? NetworkImage(_user!.profileImageUrl!)
                  : const AssetImage('assets/images/doctor_profile.jpg') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              "${_user!.firstName} ${_user!.lastName}",
              style: TextStyle(
                fontSize: ShiftslSizes.fontSizeLg,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(_user!.email, style: const TextStyle(color: Colors.black87)),
            const Text("King's Hospital", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: ShiftslSizes.defaultSpace),
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const DoctorDetailsScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShiftslColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  'View Profile',
                  style: TextStyle(
                    color: ShiftslColors.secondaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: ShiftslSizes.fontSizeMd,
                  ),
                ),
              ),
            ),
            const SizedBox(height: ShiftslSizes.defaultSpace),
            const Divider(color: ShiftslColors.darkGrey, thickness: 0.2),
            // Menu Items
            const SizedBox(height: ShiftslSizes.defaultSpace),
            ProfileMenu(
              title: 'Schedule',
              icon: Iconsax.calendar,
              onpress: () => Get.to(() => const ShiftManagementScreen()),
            ),
            ProfileMenu(
              title: 'Swap Requests',
              icon: Iconsax.arrow_swap_horizontal,
              onpress: () => Get.to(const NotificationScreen()),
            ),
            ProfileMenu(
              title: 'Leave Requests',
              icon: Iconsax.cloud_lightning,
              onpress: () => Get.to(() => const LeaveRequestsScreen()),
            ),
            ProfileMenu(
              title: 'Leave Report',
              icon: Iconsax.receipt,
              onpress: () => Get.to(() => const LeaveReportScreen()),
            ),
            const SizedBox(height: ShiftslSizes.defaultSpace),
            const Divider(color: ShiftslColors.darkGrey, thickness: 0.2),
            const SizedBox(height: ShiftslSizes.defaultSpace),
            ProfileMenu(
              title: 'Help Center',
              icon: Iconsax.message_question,
              onpress: () {},
            ),
            ProfileMenu(
              title: 'Logout',
              icon: Iconsax.logout,
              textColor: Colors.red,
              onpress: () async {
                await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Get.offAllNamed('/signIn');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget for profile menu items.
class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.title,
    required this.icon,
    required this.onpress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onpress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onpress,
      leading: Container(
        width: 50,
        height: 40,
        decoration: BoxDecoration(
          color: ShiftslColors.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ShiftslColors.secondaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: ShiftslSizes.fontSizeMd,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: endIcon ? const Icon(Iconsax.arrow_right_3, color: Colors.grey) : null,
    );
  }
}
