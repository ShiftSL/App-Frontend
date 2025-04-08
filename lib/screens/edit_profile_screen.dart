import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/user.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      setState(() {
        _errorMessage = "User not signed in";
        _isLoading = false;
      });
      return;
    }

    // Load from cache
    final cachedUser = prefs.getString('doctorData');
    if (cachedUser != null) {
      try {
        final decoded = json.decode(cachedUser);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _user = UserModel.fromJson(decoded);
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error decoding cached doctorData: $e");
      }
    }

    // Always try to fetch updated data
    await _fetchDoctorFromApi(firebaseUser.uid);
  }

  Future<void> _fetchDoctorFromApi(String firebaseUid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final url = Uri.parse("https://kings.backend.shiftsl.com/api/user/firebase/$firebaseUid");
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final fetchedUser = UserModel.fromJson(jsonData);

        await prefs.setString('doctorData', json.encode(fetchedUser.toJson()));

        if (mounted) {
          setState(() {
            _user = fetchedUser;
            _isLoading = false;
          });
        }
      } else {
        print("Failed to fetch updated doctor data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }

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

    if (_errorMessage != null || _user == null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage ?? 'Failed to load profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Details',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: ShiftslColors.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await _fetchDoctorFromApi(user.uid);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _user!.profileImageUrl != null
                      ? NetworkImage(_user!.profileImageUrl!)
                      : const AssetImage('assets/images/doctor_profile.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
