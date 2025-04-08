import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';

class LeaveShiftCardV2 extends StatelessWidget {
  final String shiftType;
  final String startTime;
  final String endTime;
  final String? formattedStartTime;
  final String? formattedEndTime;
  final DateTime? selectedDate;

  // New properties for making the leave request
  final int shiftID;
  final int doctorID;

  const LeaveShiftCardV2({
    Key? key,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    this.formattedStartTime,
    this.formattedEndTime,
    this.selectedDate,
    required this.shiftID,
    required this.doctorID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date for display, defaulting to 'Today' if not provided.
    final String formattedDate = selectedDate != null
        ? DateFormat('EEEE, d MMM').format(selectedDate!)
        : 'Today';

    // Get properly formatted time strings.
    final String displayStartTime =
        formattedStartTime ?? _formatTimeFromIso(startTime);
    final String displayEndTime =
        formattedEndTime ?? _formatTimeFromIso(endTime);

    // Choose icon based on shift type.
    IconData shiftIcon = Iconsax.sun_fog;
    if (shiftType.toLowerCase().contains("night")) {
      shiftIcon = Iconsax.moon;
    } else if (shiftType.toLowerCase().contains("day")) {
      shiftIcon = Iconsax.sun_1;
    }

    return Card(
      color: const Color(0xFFE9E9E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: ShiftslColors.primaryColor,
                  child: Icon(shiftIcon, color: ShiftslColors.secondaryColor),
                ),
                const SizedBox(width: 8),
                Text(
                  shiftType,
                  style: TextStyle(
                      color: ShiftslColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handleLeaveApplication(context, formattedDate),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      backgroundColor: ShiftslColors.secondaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    child: const Icon(
                      Iconsax.calendar_add,
                      size: 24,
                      color: ShiftslColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Removed the extra "Apply for Leave" text widget here.
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Iconsax.calendar, color: ShiftslColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                      color: ShiftslColors.primaryColor, fontSize: 14),
                ),
                const Spacer(),
                Icon(Iconsax.clock, color: ShiftslColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '$displayStartTime - $displayEndTime',
                  style: TextStyle(
                      color: ShiftslColors.primaryColor, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Handles tapping the leave application button.
  void _handleLeaveApplication(BuildContext context, String formattedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = selectedDate ?? today;

    // Check if the shift's date is in the past.
    if (selectedDay.isBefore(today)) {
      Get.snackbar(
        'Cannot Apply',
        'This session is in the past.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        margin: const EdgeInsets.all(ShiftslSizes.defaultSpace),
      );
      return;
    }

    // For shifts scheduled today, check if the start time has already passed.
    if (selectedDay.isAtSameMomentAs(today)) {
      try {
        final DateTime shiftStartTime = DateTime.parse(startTime).toLocal();
        if (now.isAfter(shiftStartTime)) {
          Get.snackbar(
            'Cannot Apply',
            'This session has already started.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[900],
            margin: const EdgeInsets.all(ShiftslSizes.defaultSpace),
          );
          return;
        }
      } catch (e) {
        print('Error parsing start time: $e');
      }
    }

    // Show a confirmation dialog.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Leave Request"),
          content: Text("Do you want to apply for leave for this shift on $formattedDate?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _makeLeaveRequest(context);
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  /// Makes the leave request API call.
  Future<void> _makeLeaveRequest(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      Get.snackbar('Error', 'No auth token found');
      return;
    }

    // Build the request payload.
    final payload = json.encode({
      "type": "CASUAL",
      "cause": "string",
      "shiftID": shiftID,
      "doctorID": doctorID,
    });

    final url = Uri.parse("https://kings.backend.shiftsl.com/api/leave/request");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Leave request submitted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900],
            margin: const EdgeInsets.all(ShiftslSizes.defaultSpace));
      } else {
        Get.snackbar('Error', 'Failed to submit leave request (Status: ${response.statusCode})',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
            margin: const EdgeInsets.all(ShiftslSizes.defaultSpace));
      }
    } catch (e) {
      Get.snackbar('Error', 'Error submitting leave request: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          margin: const EdgeInsets.all(ShiftslSizes.defaultSpace));
    }
  }

  /// Formats an ISO time string into a readable time.
  String _formatTimeFromIso(String isoTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(isoTimeString).toLocal();
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      try {
        final List<String> parts = isoTimeString.split('T');
        if (parts.length > 1) {
          final String timePart = parts[1].substring(0, 5);
          final int hour = int.tryParse(timePart.split(':')[0]) ?? 0;
          final String minute = timePart.split(':')[1];
          final String period = hour >= 12 ? 'PM' : 'AM';
          final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '$displayHour:$minute $period';
        }
      } catch (_) {}
      return isoTimeString;
    }
  }
}
