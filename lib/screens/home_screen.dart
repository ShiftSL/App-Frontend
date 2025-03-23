import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shift_sl/features/core/schedule/schedule_screen_v2.dart';
import 'package:shift_sl/screens/notification_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:shift_sl/widgets/leave_shift_card_v2.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _upcomingShifts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserShifts();
  }

  // Fetch user shifts from the API
  Future<void> _fetchUserShifts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Replace with your actual API endpoint
      final response = await http.get(Uri.parse(
          'https://spring-app-284647065201.us-central1.run.app/api/shift/14'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Filter for upcoming shifts (today and future)
        final now = DateTime.now();
        final List<Map<String, dynamic>> upcomingShifts = [];

        for (var shift in data) {
          final DateTime shiftStart =
              DateTime.parse(shift['startTime']).toLocal();

          // Only include shifts that haven't started yet
          if (shiftStart.isAfter(now)) {
            // Format the start and end times
            String formattedStartTime = _formatTime(shift['startTime']);
            String formattedEndTime = _formatTime(shift['endTime']);

            upcomingShifts.add({
              "shiftType":
                  _determineShiftType(shift['startTime'], shift['endTime']),
              "startTime": shift['startTime'],
              "endTime": shift['endTime'],
              "formattedStartTime": formattedStartTime,
              "formattedEndTime": formattedEndTime,
              "shiftDate": shiftStart,
            });
          }
        }

        // Sort shifts by start time (earliest first)
        upcomingShifts.sort((a, b) =>
            (a["shiftDate"] as DateTime).compareTo(b["shiftDate"] as DateTime));

        // Take at most 3 shifts (next shift + 2 upcoming)
        final limitedShifts = upcomingShifts.take(3).toList();

        setState(() {
          _upcomingShifts = limitedShifts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load shift data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching shift data: $e';
        _isLoading = false;
      });
    }
  }

  // Format time from ISO string to readable format
  String _formatTime(String isoTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(isoTimeString).toLocal();
      return DateFormat('h:mm a').format(dateTime); // e.g., "9:00 AM"
    } catch (e) {
      return isoTimeString; // Return original string if parsing fails
    }
  }

  // Determine shift type based on start time
  String _determineShiftType(String startTime, String endTime) {
    int startHour = int.tryParse(startTime.split('T')[1].split(':')[0]) ?? 0;

    if (startHour >= 6 && startHour < 12) {
      return "Morning Shift";
    } else if (startHour >= 12 && startHour < 18) {
      return "Day Shift";
    } else {
      return "Night Shift";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Image.asset(
          'assets/images/shift_sl_logo.png',
          height: 100,
          width: 120,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            onPressed: () => Get.to(() => const NotificationScreen()),
            icon: const Icon(Iconsax.notification_bing5),
            color: ShiftslColors.primaryColor,
            iconSize: 30,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Greeting Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShiftslColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage('assets/images/doctor_profile.jpg'),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Hello!',
                          style: TextStyle(
                            color: ShiftslColors.white,
                            fontSize: ShiftslSizes.fontSizeMd,
                            fontWeight: FontWeight.w400,
                          )),
                      SizedBox(height: 4),
                      Text(
                        'Dr. Adam Levine',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ShiftslSizes.fontSizeLg,
                          color: ShiftslColors.white,
                        ),
                      ),
                      Text("King's Hospital",
                          style: TextStyle(
                              color: ShiftslColors.secondaryColor,
                              fontSize: ShiftslSizes.fontSizeMd,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: ShiftslSizes.defaultSpace),

            // Schedule published card
            Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShiftslColors.primaryColor,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    'New Schedule Published!',
                    style: TextStyle(
                      color: ShiftslColors.white,
                      fontSize: ShiftslSizes.fontSizeMd,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 130,
                    height: 50,
                    child: FilledButton(
                      onPressed: () => Get.to(() => ShiftManagementScreen()),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        backgroundColor: ShiftslColors.secondaryColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        side: BorderSide.none,
                      ),
                      child: const Text(
                        'View Schedule',
                        style: TextStyle(
                            color: ShiftslColors.primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: ShiftslSizes.fontSizeMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ShiftslSizes.defaultSpace),

            // "Your Next Shift" Section
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Next Shift",
                  style: TextStyle(
                    color: ShiftslColors.primaryColor,
                    fontSize: ShiftslSizes.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Next Shift Card
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _upcomingShifts.isEmpty
                        ? _buildNoShiftsWidget("No upcoming shifts found")
                        : LeaveShiftCardV2(
                            shiftType: _upcomingShifts[0]["shiftType"],
                            startTime: _upcomingShifts[0]["startTime"],
                            endTime: _upcomingShifts[0]["endTime"],
                            formattedStartTime: _upcomingShifts[0]
                                ["formattedStartTime"],
                            formattedEndTime: _upcomingShifts[0]
                                ["formattedEndTime"],
                            selectedDate: _upcomingShifts[0]["shiftDate"],
                          ),

            const SizedBox(height: ShiftslSizes.defaultSpace),

            // "Upcoming Shifts" Section
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Upcoming Shifts",
                  style: TextStyle(
                    color: ShiftslColors.primaryColor,
                    fontSize: ShiftslSizes.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Upcoming Shifts Cards
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _upcomingShifts.length <= 1
                        ? _buildNoShiftsWidget(
                            "No additional upcoming shifts found")
                        : Column(
                            children: [
                              for (int i = 1; i < _upcomingShifts.length; i++)
                                Column(
                                  children: [
                                    LeaveShiftCardV2(
                                      shiftType: _upcomingShifts[i]
                                          ["shiftType"],
                                      startTime: _upcomingShifts[i]
                                          ["startTime"],
                                      endTime: _upcomingShifts[i]["endTime"],
                                      formattedStartTime: _upcomingShifts[i]
                                          ["formattedStartTime"],
                                      formattedEndTime: _upcomingShifts[i]
                                          ["formattedEndTime"],
                                      selectedDate: _upcomingShifts[i]
                                          ["shiftDate"],
                                    ),
                                    if (i < _upcomingShifts.length - 1)
                                      const SizedBox(height: 10),
                                  ],
                                ),
                            ],
                          ),
          ],
        ),
      ),
    );
  }

  // Error widget
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? "An error occurred",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[800]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _fetchUserShifts,
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }

  // No shifts widget
  Widget _buildNoShiftsWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.calendar, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
