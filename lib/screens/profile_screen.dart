import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import 'edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';

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

  /// Retrieves the user's profile data from the API.
  Future<void> _loadProfile() async {
    // Get the current Firebase user
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() {
        _errorMessage = "User not signed in";
        _isLoading = false;
      });
      return;
    }

    // Retrieve the stored auth token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      setState(() {
        _errorMessage = "No auth token found";
        _isLoading = false;
      });
      return;
    }

    // Construct the API URL using the Firebase UID
    final url = Uri.parse(
      "https://kings.backend.shiftsl.com/api/user/firebase/${firebaseUser.uid}",
    );
    print("Fetching profile data from $url with token: $token");

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      });

      print("Profile response status: ${response.statusCode}");
      print("Profile response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _user = UserModel.fromJson(jsonData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
          "Failed to load profile data: ${response.statusCode}";
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(ShiftslSizes.defaultSpace),
          child: Column(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: _user!.profileImageUrl != null
                      ? Image.network(_user!.profileImageUrl!,
                      fit: BoxFit.cover)
                      : Image.asset('assets/images/doctor_profile.jpg'),
                ),
              ),
              const SizedBox(height: 10),
              // Display doctor's name
              Text(
                "${_user!.firstName} ${_user!.lastName}",
                style: TextStyle(
                  fontSize: ShiftslSizes.fontSizeLg,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Display email address
              Text(
                _user!.email,
                style: TextStyle(
                  fontSize: ShiftslSizes.fontSizeMd,
                  color: const Color(0xFF131313),
                ),
              ),
              Text("King's Hospital",
                  style: TextStyle(
                    fontSize: ShiftslSizes.fontSizeMd,
                    color: const Color(0xFF131313),
                  )),
              const SizedBox(height: ShiftslSizes.defaultSpace),
              // Edit Profile button
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const DoctorDetailsScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ShiftslColors.primaryColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    side: BorderSide.none,
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
              const Divider(
                color: ShiftslColors.darkGrey,
                thickness: 0.2,
              ),
              const SizedBox(height: ShiftslSizes.defaultSpace),
              // Menu Items
              ProfileMenu(
                title: 'Schedule',
                icon: Iconsax.calendar,
                onpress: () {},
              ),
              ProfileMenu(
                title: 'Swap Requests',
                icon: Iconsax.arrow_swap_horizontal,
                onpress: () {},
              ),
              ProfileMenu(
                title: 'Leave Requests',
                icon: Iconsax.cloud_lightning,
                onpress: () {},
              ),
              ProfileMenu(
                title: 'Leave Report',
                icon: Iconsax.receipt,
                onpress: () {},
              ),
              const SizedBox(height: ShiftslSizes.defaultSpace),
              const Divider(
                color: ShiftslColors.darkGrey,
                thickness: 0.2,
              ),
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
                  // Log out the user
                  await FirebaseAuth.instance.signOut();
                  // Navigate to the sign-in screen (adjust route as needed)
                  Get.offAllNamed('/signIn');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.title,
    required this.icon,
    required this.onpress,
    this.endIcon = true,
    this.textColor,
  });

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
        child: Icon(
          icon,
          color: ShiftslColors.secondaryColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF131313),
          fontSize: ShiftslSizes.fontSizeMd,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(Iconsax.arrow_right_3, color: Colors.grey),
    );
  }
}
