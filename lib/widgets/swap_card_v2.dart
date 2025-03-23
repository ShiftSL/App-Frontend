import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:intl/intl.dart';

class SwapCardV2 extends StatelessWidget {
  final String doctorName;
  final String shiftType;
  final String startTime;
  final String endTime;
  final String? formattedStartTime;
  final String? formattedEndTime;
  final DateTime? selectedDate;

  const SwapCardV2({
    Key? key,
    required this.doctorName,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    this.formattedStartTime,
    this.formattedEndTime,
    this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    final String formattedDate = selectedDate != null
        ? DateFormat('EEEE, d MMM')
            .format(selectedDate!) // e.g., "Monday, 21 Mar"
        : 'Today';

    // Get properly formatted time strings
    final String displayStartTime =
        formattedStartTime ?? _formatTimeFromIso(startTime);
    final String displayEndTime =
        formattedEndTime ?? _formatTimeFromIso(endTime);

    // Choose icon based on shift type
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
                  doctorName,
                  style: TextStyle(
                      color: ShiftslColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  shiftType,
                  style: TextStyle(
                      color: ShiftslColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handleLeaveApplication(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      backgroundColor: ShiftslColors.secondaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      side: BorderSide.none,
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
            const SizedBox(
              height: 20,
              width: double.infinity,
              child: Text(
                'Swap Shift',
                textAlign: TextAlign.right,
                style:
                    TextStyle(color: ShiftslColors.primaryColor, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Iconsax.arrow_swap, color: ShiftslColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                      color: ShiftslColors.primaryColor, fontSize: 14),
                ),
                Spacer(),
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

  // Handle the leave application button press
  void _handleLeaveApplication(BuildContext context) {
    // Check if selected date is in the past
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = selectedDate ?? today;

    // 1. Check if the shift date is in the past
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

    // 2. Check if the shift has already started today
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
        // If parsing fails, still proceed to the edit screen
        print('Error parsing start time: $e');
      }
    }

    // If all checks pass, navigate to the edit profile screen
    Get.to(() => const EditProfileScreen());
  }

  // Format time from ISO string to readable format (fallback method)
  String _formatTimeFromIso(String isoTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(isoTimeString).toLocal();
      return DateFormat('h:mm a').format(dateTime); // e.g., "9:00 AM"
    } catch (e) {
      // Fallback to manual parsing if DateTime.parse fails
      try {
        final List<String> parts = isoTimeString.split('T');
        if (parts.length > 1) {
          final String timePart = parts[1].substring(0, 5); // Get HH:MM
          final int hour = int.tryParse(timePart.split(':')[0]) ?? 0;
          final String minute = timePart.split(':')[1];
          final String period = hour >= 12 ? 'PM' : 'AM';
          final int displayHour =
              hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '$displayHour:$minute $period';
        }
      } catch (_) {
        // If manual parsing fails too, just return the original
      }
      return isoTimeString; // Return original if all parsing fails
    }
  }
}
