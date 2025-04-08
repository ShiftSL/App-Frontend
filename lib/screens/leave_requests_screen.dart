import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import '../models/user.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({Key? key}) : super(key: key);

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  List<dynamic> _leaveRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserAndRequests();
  }

  Future<void> _loadUserAndRequests() async {
    final prefs = await SharedPreferences.getInstance();
    // Load cached user data
    final cachedUserData = prefs.getString('doctorData');
    if (cachedUserData != null) {
      try {
        final decoded = json.decode(cachedUserData);
        _user = UserModel.fromJson(decoded);
      } catch (e) {
        print("Error decoding user data: $e");
      }
    }
    // Ensure user is loaded
    if (_user == null) {
      setState(() {
        _errorMessage = "User data unavailable.";
        _isLoading = false;
      });
      return;
    }
    _fetchLeaveRequests();
  }

  Future<void> _fetchLeaveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      setState(() {
        _errorMessage = "No auth token found.";
        _isLoading = false;
      });
      return;
    }
    try {
      // Adjust the endpoint if needed. This example uses a doctor-specific endpoint.
      final url = Uri.parse("https://kings.backend.shiftsl.com/api/leave/byDoc/${_user!.id}");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _leaveRequests = data; // Expecting a list of leave requests
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load leave requests: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching leave requests: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests', style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _leaveRequests.isEmpty
          ? const Center(child: Text("No leave requests found."))
          : ListView.builder(
        padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
        itemCount: _leaveRequests.length,
        itemBuilder: (context, index) {
          final leave = _leaveRequests[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Iconsax.document, color: ShiftslColors.primaryColor),
              title: Text("Type: ${leave['type']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cause: ${leave['cause']}"),
                  Text("Status: ${leave['status']}"),
                  if (leave['shift'] != null)
                    Text("Shift: ${leave['shift']['startTime']} - ${leave['shift']['endTime']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
