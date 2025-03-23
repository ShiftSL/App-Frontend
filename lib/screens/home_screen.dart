import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:shift_sl/utils/secure_storage.dart';
import 'package:shift_sl/widgets/leave_shift_card_v2.dart';
import 'package:shift_sl/screens/notification_screen.dart';
import 'package:shift_sl/features/core/schedule/schedule_screen_v2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String doctorName = "";
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _upcomingShifts = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndShifts();
  }

  Future<void> _loadUserAndShifts() async {
    try {
      final userJson = await SecureStorage.getUser();
      final token = await SecureStorage.getToken();

      if (userJson == null || token == null) {
        setState(() {
          _errorMessage = "Authentication failed. Please login again.";
          _isLoading = false;
        });
        return;
      }

      final user = jsonDecode(userJson);
      final int userId = user['id'];
      doctorName = "Dr. ${user['firstName']} ${user['lastName']}";

      await _fetchShifts(userId, token);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load user data.";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchShifts(int userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse("https://spring-app-284647065201.us-central1.run.app/api/shift/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final now = DateTime.now();
        final List<Map<String, dynamic>> filtered = [];

        for (var shift in data) {
          final start = DateTime.parse(shift['startTime']).toLocal();
          if (start.isAfter(now)) {
            filtered.add({
              "shiftType": _getShiftType(shift['startTime']),
              "startTime": shift['startTime'],
              "endTime": shift['endTime'],
              "formattedStartTime": _formatTime(shift['startTime']),
              "formattedEndTime": _formatTime(shift['endTime']),
              "shiftDate": start,
            });
          }
        }

        filtered.sort((a, b) => (a['shiftDate'] as DateTime).compareTo(b['shiftDate'] as DateTime));

        setState(() {
          _upcomingShifts = filtered.take(3).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Error loading shifts (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error: $e";
        _isLoading = false;
      });
    }
  }

  String _formatTime(String iso) {
    try {
      return DateFormat('h:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  String _getShiftType(String startTime) {
    final hour = DateTime.parse(startTime).toLocal().hour;
    if (hour >= 6 && hour < 12) return "Morning Shift";
    if (hour >= 12 && hour < 18) return "Day Shift";
    return "Night Shift";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        title: Image.asset('assets/images/shift_sl_logo.png', height: 100, width: 120),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification_bing5, size: 30),
            color: ShiftslColors.primaryColor,
            onPressed: () => Get.to(() => const NotificationScreen()),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGreetingCard(),
            const SizedBox(height: ShiftslSizes.defaultSpace),
            _buildSchedulePublishedCard(),
            const SizedBox(height: ShiftslSizes.defaultSpace),
            _buildNextShiftSection(),
            const SizedBox(height: ShiftslSizes.defaultSpace),
            _buildUpcomingShiftsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShiftslColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/doctor_profile.jpg'),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hello!",
                  style: TextStyle(
                      color: ShiftslColors.white,
                      fontSize: ShiftslSizes.fontSizeMd,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              Text(
                doctorName.isEmpty ? "Doctor" : doctorName,
                style: const TextStyle(
                  color: ShiftslColors.white,
                  fontSize: ShiftslSizes.fontSizeLg,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text("King's Hospital",
                  style: TextStyle(
                      color: ShiftslColors.secondaryColor,
                      fontSize: ShiftslSizes.fontSizeMd))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSchedulePublishedCard() {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShiftslColors.primaryColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('New Schedule Published!',
              style: TextStyle(
                  color: ShiftslColors.white,
                  fontSize: ShiftslSizes.fontSizeMd,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          SizedBox(
            width: 130,
            height: 50,
            child: FilledButton(
              onPressed: () => Get.to(() =>  ShiftManagementScreen()),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: ShiftslColors.secondaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'View Schedule',
                style: TextStyle(
                  color: ShiftslColors.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: ShiftslSizes.fontSizeMd,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNextShiftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Next Shift",
            style: TextStyle(
                color: ShiftslColors.primaryColor,
                fontSize: ShiftslSizes.fontSizeLg,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_errorMessage != null)
          _buildErrorCard(_errorMessage!)
        else if (_upcomingShifts.isEmpty)
            _buildInfoCard("No upcoming shifts found.")
          else
            LeaveShiftCardV2(
              shiftType: _upcomingShifts[0]["shiftType"],
              startTime: _upcomingShifts[0]["startTime"],
              endTime: _upcomingShifts[0]["endTime"],
              formattedStartTime: _upcomingShifts[0]["formattedStartTime"],
              formattedEndTime: _upcomingShifts[0]["formattedEndTime"],
              selectedDate: _upcomingShifts[0]["shiftDate"],
            ),
      ],
    );
  }

  Widget _buildUpcomingShiftsSection() {
    if (_upcomingShifts.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upcoming Shifts",
            style: TextStyle(
                color: ShiftslColors.primaryColor,
                fontSize: ShiftslSizes.fontSizeLg,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...List.generate(_upcomingShifts.length - 1, (index) {
          final shift = _upcomingShifts[index + 1];
          return Column(
            children: [
              LeaveShiftCardV2(
                shiftType: shift["shiftType"],
                startTime: shift["startTime"],
                endTime: shift["endTime"],
                formattedStartTime: shift["formattedStartTime"],
                formattedEndTime: shift["formattedEndTime"],
                selectedDate: shift["shiftDate"],
              ),
              const SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: Colors.red[800]))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.calendar, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }
}
