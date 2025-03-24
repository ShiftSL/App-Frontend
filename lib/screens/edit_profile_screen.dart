import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart'; // Ensure your UserModel includes the needed fields.
import '../utils/constants/colors.dart';
import '../utils/constants/sizes.dart';

class DoctorDetailsScreen extends StatefulWidget {
  const DoctorDetailsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDoctorDetails();
  }

  Future<void> _loadDoctorDetails() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() {
        _errorMessage = "User not signed in";
        _isLoading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      setState(() {
        _errorMessage = "No auth token found";
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        "https://kings.backend.shiftsl.com/api/user/firebase/${firebaseUser.uid}");
    print("Fetching doctor details from $url with token: $token");

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _user = UserModel.fromJson(jsonData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load doctor details: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching doctor details: $e";
        _isLoading = false;
      });
    }
  }

  /// Helper widget to display a detail row.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: ShiftslSizes.fontSizeMd,
                fontWeight: FontWeight.bold,
                color: ShiftslColors.primaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ShiftslSizes.fontSizeMd,
                color: ShiftslColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
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
          'Doctor Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: ShiftslColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image (network image if available; otherwise a fallback)
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _user!.profileImageUrl != null
                    ? NetworkImage(_user!.profileImageUrl!)
                    : const AssetImage('assets/images/doctor_profile.jpg')
                as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            // Doctor Name
            Center(
              child: Text(
                "${_user!.firstName} ${_user!.lastName}",
                style: TextStyle(
                  fontSize: ShiftslSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: ShiftslColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Hardcoded Hospital Name
            Center(
              child: Text(
                "King's Hospital",
                style: TextStyle(
                  fontSize: ShiftslSizes.fontSizeMd,
                  color: ShiftslColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Details
            _buildDetailRow("Email", _user!.email),
            const Divider(),
            _buildDetailRow("Phone", _user!.phoneNo ?? "Not available"),
            const Divider(),
            _buildDetailRow(
              "Role",
              _user!.role == "DOCTOR_PERM"
                  ? "Permanent"
                  : _user!.role == "DOCTOR_TEMP"
                  ? "Temporary"
                  : _user!.role,
            ),
            const Divider(),
            // Additional details can be added here.
          ],
        ),
      ),
    );
  }
}
