import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_sl/features/core/schedule/tab_item.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:shift_sl/widgets/leave_shift_card_v2.dart';
import 'package:shift_sl/widgets/swap_card_v2.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../models/user.dart';
import '../../../services/User_service.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({Key? key}) : super(key: key);

  @override
  _ShiftManagementScreenState createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  UserModel? _user;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Two separate data maps for My Shifts and All Shifts
  Map<DateTime, List<Map<String, dynamic>>> _myShiftData = {};
  Map<DateTime, List<Map<String, dynamic>>> _allShiftData = {};

  // Separate loading and error states
  bool _isMyLoading = false;
  bool _isAllLoading = false;
  String? _myErrorMessage;
  String? _allErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // If user is logged in, fetch user data, then fetch shifts
      fetchUserByFirebaseUid(firebaseUser.uid).then((userDetails) {
        if (!mounted) return;
        setState(() => _user = userDetails);

        if (_user != null) {
          _fetchMyShiftData();
          _fetchAllShiftData();
        } else {
          setState(() {
            _isMyLoading = false;
            _isAllLoading = false;
          });
        }
      });
    } else {
      // No Firebase user found
      setState(() {
        _isMyLoading = false;
        _isAllLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Fetch user details from API using Firebase UID and Bearer token.
  Future<UserModel?> fetchUserByFirebaseUid(String firebaseUid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return null;

    final url = Uri.parse("https://kings.backend.shiftsl.com/api/user/firebase/$firebaseUid");
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        return UserModel.fromJson(jsonData);
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Fetch My Shifts for the logged-in user.
  Future<void> _fetchMyShiftData() async {
    setState(() {
      _isMyLoading = true;
      _myErrorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) throw Exception('No auth token found');
      final doctorId = _user!.id;

      final url = Uri.parse("https://kings.backend.shiftsl.com/api/shift/$doctorId");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<DateTime, List<Map<String, dynamic>>> groupedShifts = {};

        // Group shifts by date
        for (var shift in data) {
          final shiftDate = DateTime.parse(shift['startTime']).toLocal().dateOnly();
          groupedShifts.putIfAbsent(shiftDate, () => []);

          final formattedStartTime = _formatTime(shift['startTime']);
          final formattedEndTime = _formatTime(shift['endTime']);

          groupedShifts[shiftDate]!.add({
            "shiftType": _determineShiftType(shift['startTime'], shift['endTime']),
            "startTime": shift['startTime'],
            "endTime": shift['endTime'],
            "formattedStartTime": formattedStartTime,
            "formattedEndTime": formattedEndTime,
          });
        }

        setState(() {
          _myShiftData = groupedShifts;
          _isMyLoading = false;
        });
      } else {
        setState(() {
          _myErrorMessage = 'Failed to load My Shifts: ${response.statusCode}';
          _isMyLoading = false;
          _myShiftData = {};
        });
      }
    } catch (e) {
      setState(() {
        _myErrorMessage = 'Error fetching My Shifts: $e';
        _isMyLoading = false;
        _myShiftData = {};
      });
    }
  }

  /// Fetch All Shifts from the endpoint returning every shift.
  Future<void> _fetchAllShiftData() async {
    setState(() {
      _isAllLoading = true;
      _allErrorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) throw Exception('No auth token found');

      final url = Uri.parse("https://kings.backend.shiftsl.com/api/shift");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Temporary map to group by date
        final Map<DateTime, List<Map<String, dynamic>>> groupedShifts = {};

        for (var shift in data) {
          final shiftDate =
          DateTime.parse(shift['startTime']).toLocal().dateOnly();
          groupedShifts.putIfAbsent(shiftDate, () => []);

          // 1) Build a comma-separated list of the doctors' names
          String doctorNames = "";
          if (shift['doctors'] != null && shift['doctors'] is List) {
            final doctorsList = shift['doctors'] as List;
            final nameList = <String>[];

            for (var doctor in doctorsList) {
              final fName = doctor['firstName'] ?? '';
              final lName = doctor['lastName'] ?? '';
              final fullName = "$fName $lName".trim();
              if (fullName.isNotEmpty) {
                nameList.add(fullName);
              }
            }
            // Join all doctor names into a single string
            doctorNames = nameList.join(', ');
          }

          // 2) Format times for readability
          final formattedStartTime = _formatTime(shift['startTime']);
          final formattedEndTime = _formatTime(shift['endTime']);

          // 3) Determine shift type
          final shiftType =
          _determineShiftType(shift['startTime'], shift['endTime']);

          // 4) Store the parsed data
          groupedShifts[shiftDate]!.add({
            "shiftType": shiftType,
            "startTime": shift['startTime'],
            "endTime": shift['endTime'],
            "formattedStartTime": formattedStartTime,
            "formattedEndTime": formattedEndTime,
            "doctorNames": doctorNames, // <-- assigned doctors
          });
        }

        setState(() {
          _allShiftData = groupedShifts;
          _isAllLoading = false;
        });
      } else {
        setState(() {
          _allErrorMessage =
          'Failed to load All Shifts: ${response.statusCode}';
          _isAllLoading = false;
          _allShiftData = {};
        });
      }
    } catch (e) {
      setState(() {
        _allErrorMessage = 'Error fetching All Shifts: $e';
        _isAllLoading = false;
        _allShiftData = {};
      });
    }
  }


  /// Convert an ISO time string to a user-friendly format (e.g., "9:00 AM").
  String _formatTime(String isoTimeString) {
    try {
      final dateTime = DateTime.parse(isoTimeString).toLocal();
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return isoTimeString;
    }
  }

  /// Determine shift type (morning/day/night) based on the start hour.
  String _determineShiftType(String startTime, String endTime) {
    final startHour = int.tryParse(startTime.split('T')[1].split(':')[0]) ?? 0;
    if (startHour >= 6 && startHour < 12) {
      return "Morning Shift";
    } else if (startHour >= 12 && startHour < 18) {
      return "Day Shift";
    } else {
      return "Night Shift";
    }
  }

  /// Called when the user taps a day in the calendar.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  /// Simple method to style each day on the calendar.
  Widget _calendarBuilder(BuildContext context, DateTime day, DateTime focusedDay) {
    final today = DateTime.now().dateOnly();
    final isToday = isSameDay(day, today);

    // Show a small dot for "today"
    Widget? dayMarker = isToday
        ? Container(
      margin: const EdgeInsets.all(0),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: ShiftslColors.secondaryColor,
      ),
      width: 8,
      height: 8,
    )
        : null;

    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: isSameDay(day, _selectedDay)
          ? BoxDecoration(
        color: Colors.black12,
        shape: BoxShape.circle,
      )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${day.day}',
            style: isToday
                ? const TextStyle(
              color: ShiftslColors.primaryColor,
              fontWeight: FontWeight.bold,
            )
                : null,
          ),
          if (dayMarker != null) dayMarker,
        ],
      ),
    );
  }

  /// Tab 1: My Shifts
  Widget _buildMyShiftsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendar(
            eventsLoader: (day) => _myShiftData[day.dateOnly()] ?? [],
          ),
          const SizedBox(height: 16),
          Text(
            'Selected Day: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildMyShiftContent(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Tab 2: All Shifts (Schedule View)
  Widget _buildAllShiftsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendar(
            eventsLoader: (day) => _allShiftData[day.dateOnly()] ?? [],
          ),
          const SizedBox(height: 16),
          Text(
            'Selected Day: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildAllShiftContent(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Reusable calendar widget for each tab
  Widget _buildCalendar({
    required List<dynamic> Function(DateTime) eventsLoader,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        calendarBuilders: CalendarBuilders(
          defaultBuilder: _calendarBuilder,
        ),
        locale: 'en_US',
        rowHeight: 50,
        focusedDay: _focusedDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        availableGestures: AvailableGestures.all,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        onDaySelected: _onDaySelected,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        eventLoader: eventsLoader,
      ),
    );
  }

  /// "My Shifts" content for the selected day
  Widget _buildMyShiftContent() {
    if (_isMyLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_myErrorMessage != null) {
      return _buildErrorMessage(
        message: _myErrorMessage!,
        retryCallback: _fetchMyShiftData,
      );
    }

    final shifts = _myShiftData[_selectedDay.dateOnly()] ?? [];
    if (shifts.isEmpty) {
      return _buildEmptyMessage("No shift scheduled for this day");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: shifts.map((shift) {
          return LeaveShiftCardV2(
            shiftType: shift["shiftType"],
            startTime: shift["startTime"],
            endTime: shift["endTime"],
            formattedStartTime: shift["formattedStartTime"],
            formattedEndTime: shift["formattedEndTime"],
            selectedDate: _selectedDay,
          );
        }).toList(),
      ),
    );
  }

  /// "All Shifts" content for the selected day
  /// "All Shifts" content for the selected day
  Widget _buildAllShiftContent() {
    if (_isAllLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allErrorMessage != null) {
      return _buildErrorMessage(
        message: _allErrorMessage!,
        retryCallback: _fetchAllShiftData,
      );
    }

    final shifts = _allShiftData[_selectedDay.dateOnly()] ?? [];
    if (shifts.isEmpty) {
      return _buildEmptyMessage("No shift scheduled for this day");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: shifts.map((shift) {
          return SwapCardV2(
            // Display the list of assigned doctors:
            doctorName: shift["doctorNames"] ?? "Unassigned",
            shiftType: shift["shiftType"],
            startTime: shift["startTime"],
            endTime: shift["endTime"],
            formattedStartTime: shift["formattedStartTime"],
            formattedEndTime: shift["formattedEndTime"],
            selectedDate: _selectedDay,
          );
        }).toList(),
      ),
    );
  }

  /// Display an error message and a Retry button
  Widget _buildErrorMessage({
    required String message,
    required VoidCallback retryCallback,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: retryCallback,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Display a simple empty message
  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color(0xFFFFFFFF),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: const BoxDecoration(
                  color: ShiftslColors.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: ShiftslColors.primaryColor,
                tabs: const [
                  TabItem(title: 'My Shifts'),
                  TabItem(title: 'Schedule View'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyShiftsTab(),
          _buildAllShiftsTab(),
        ],
      ),
    );
  }
}

/// Extension to trim a [DateTime] to YYYY-MM-DD only.
extension DateOnly on DateTime {
  DateTime dateOnly() {
    return DateTime(year, month, day);
  }
}
