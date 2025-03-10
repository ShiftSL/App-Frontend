import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// Mock JSON data for shifts.
/// Keys are dates in yyyy-MM-dd format.
/// Note: We no longer include "startHour" in the JSON.
/// Instead, we derive it from the shift type.
final Map<String, List<Map<String, String>>> mockShifts = {
  '2025-02-20': [
    {
      'timeLabel': 'Morning',
      'timeRange': '6:00 AM - 12:00 Noon',
      'status': 'Attended',
    },
    {
      'timeLabel': 'Day',
      'timeRange': '12:00 Noon - 6:00 PM',
      'status': 'Leave',
    },
  ],
  '2025-02-21': [
    {
      'timeLabel': 'Morning',
      'timeRange': '6:00 AM - 12:00 Noon',
      'status': 'Leave',
    },
    {
      'timeLabel': 'Night',
      'timeRange': '6:00 PM - 6:00 AM',
      'status': 'Leave',
    },
  ],
  '2025-02-25': [
    {
      'timeLabel': 'Morning',
      'timeRange': '6:00 AM - 12:00 Noon',
      'status': 'Leave',
    },
  ],
};

/// Helper function that returns the start hour (0-23) based on shift type.
int getStartHour(String shiftType) {
  switch (shiftType.toLowerCase()) {
    case 'morning':
      return 6;
    case 'day':
      return 12;
    case 'night':
      return 18;
    default:
      return 0;
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _shiftsForSelectedDay = [];

  @override
  void initState() {
    super.initState();
    _fetchShiftsForDate(_selectedDay);
  }

  /// Fetch shifts for the given date.
  /// In a real app, replace this with an API call.
  void _fetchShiftsForDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      // Convert the mockShifts maps to dynamic so we can update the status later.
      _shiftsForSelectedDay = List<Map<String, dynamic>>.from(
          mockShifts[dateKey] ?? []);
    });
  }

  /// Handle tap on a shift card.
  /// - If the selected date is in the past, show a message (read-only).
  /// - For today's date, calculate the shift start hour from the shift type.
  ///   If current hour >= shift start hour, then the session has already started.
  /// - Otherwise, open the status update dialog.
  void _handleShiftTap(Map<String, dynamic> shiftData) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final selectedOnly = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    if (selectedOnly.isBefore(todayOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This session is in the past.')),
      );
      return;
    }
    if (DateUtils.isSameDay(selectedOnly, todayOnly)) {
      final String shiftType = shiftData['timeLabel'] ?? '';
      final int shiftStartHour = getStartHour(shiftType);
      if (now.hour >= shiftStartHour) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This session has already started.')),
        );
        return;
      }
    }
    _showStatusDialog(shiftData);
  }

  /// Show a dialog to update the shift status.
  void _showStatusDialog(Map<String, dynamic> shiftData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Shift Status'),
          content: const Text('Mark this session as Attended or Leave?'),
          actions: [
            TextButton(
              onPressed: () {
                _updateShiftStatus(shiftData, 'Attended');
                Navigator.pop(context);
              },
              child: const Text('Attended'),
            ),
            TextButton(
              onPressed: () {
                _updateShiftStatus(shiftData, 'Leave');
                Navigator.pop(context);
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  /// Update the shift's status and (optionally) call an API to persist the change.
  void _updateShiftStatus(Map<String, dynamic> shiftData, String newStatus) {
    setState(() {
      shiftData['status'] = newStatus;
    });
    // TODO: Call your backend API here to update the shift status.
    // e.g., await ShiftService.updateShiftStatus(doctorId, shiftData['id'], newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final focusedDay = _selectedDay;
    final formattedDate = DateFormat('EEEE, MMM d').format(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Scrollable content: Calendar and shift list.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: focusedDay,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                      });
                      _fetchShiftsForDate(selectedDay);
                    },
                    calendarStyle: const CalendarStyle(
                      defaultTextStyle: TextStyle(color: Colors.black),
                      disabledTextStyle: TextStyle(color: Colors.grey),
                    ),
                    // Use calendarBuilders to display past dates in gray.
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        if (day.isBefore(DateTime.now())) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return null;
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        if (day.isBefore(DateTime.now())) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Shifts for $formattedDate',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _shiftsForSelectedDay.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No shifts for this date'),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _shiftsForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final shift = _shiftsForSelectedDay[index];
                      return GestureDetector(
                        onTap: () => _handleShiftTap(shift),
                        child: _buildShiftCard(shift),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Bottom fixed button row.
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "Apply for Leave" button.
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2AED8D),
                    fixedSize: const Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/applyForLeave'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.post_add),
                      SizedBox(height: 4),
                      Text('Leave'),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // "Swap Shifts" button.
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2AED8D),
                    fixedSize: const Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/swaps'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.swap_horiz),
                      SizedBox(height: 4),
                      Text('Swap'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a shift card widget.
  Widget _buildShiftCard(Map<String, dynamic> shiftData) {
    final String timeLabel = shiftData['timeLabel'] ?? 'Shift';
    final String timeRange = shiftData['timeRange'] ?? '';
    final String status = shiftData['status'] ?? 'Leave';

    // Determine the status color.
    Color statusColor;
    if (status.toLowerCase() == 'attended' || status.toLowerCase() == 'attending') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'leave' || status.toLowerCase() == 'not attending') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.blueGrey;
    }

    // Choose an icon based on timeLabel.
    String iconPath;
    if (timeLabel.toLowerCase().contains('morning')) {
      iconPath = 'assets/icons/morning.png';
    } else if (timeLabel.toLowerCase().contains('night')) {
      iconPath = 'assets/icons/half-moon.png';
    } else {
      iconPath = 'assets/icons/sun.png';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white,
            child: Image.asset(
              iconPath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          // Shift details.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  timeRange,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status pill.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
