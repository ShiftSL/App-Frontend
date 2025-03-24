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
  ShiftManagementScreen({Key? key}) : super(key: key);

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

    // Retrieve the Firebase user and fetch user details.
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      fetchUserByFirebaseUid(firebaseUser.uid).then((userDetails) {
        if (!mounted) return;
        setState(() {
          _user = userDetails;
        });
        // Fetch both My Shifts and All Shifts when user details are available.
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
    if (token == null) {
      print('No auth token found');
      return null;
    }
    final url = Uri.parse("https://kings.backend.shiftsl.com/api/user/firebase/$firebaseUid");
    print("Fetching user data from $url with token: $token");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    print("User response status code: ${response.statusCode}");
    print("User response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        return UserModel.fromJson(jsonData);
      } catch (e) {
        print("Error parsing user data: $e");
        return null;
      }
    } else {
      print("Failed to load user data, status code: ${response.statusCode}");
      return null;
    }
  }

  /// Service 1: Fetch My Shifts using the dynamic doctor id.
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
      final url = Uri.parse('https://kings.backend.shiftsl.com/api/shift/$doctorId');
      print("Fetching My Shifts from $url with token: $token");

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Group shifts by date.
        final Map<DateTime, List<Map<String, dynamic>>> groupedShifts = {};
        for (var shift in data) {
          DateTime shiftDate = DateTime.parse(shift['startTime']).toLocal().dateOnly();
          if (!groupedShifts.containsKey(shiftDate)) {
            groupedShifts[shiftDate] = [];
          }
          String formattedStartTime = _formatTime(shift['startTime']);
          String formattedEndTime = _formatTime(shift['endTime']);

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

  /// Service 2: Fetch All Shifts from the endpoint that returns every shift.
  Future<void> _fetchAllShiftData() async {
    setState(() {
      _isAllLoading = true;
      _allErrorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) throw Exception('No auth token found');

      // All shifts endpoint (without doctor id)
      final url = Uri.parse('https://kings.backend.shiftsl.com/api/shift/');
      print("Fetching All Shifts from $url with token: $token");

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Group shifts by date.
        final Map<DateTime, List<Map<String, dynamic>>> groupedShifts = {};
        for (var shift in data) {
          DateTime shiftDate = DateTime.parse(shift['startTime']).toLocal().dateOnly();
          if (!groupedShifts.containsKey(shiftDate)) {
            groupedShifts[shiftDate] = [];
          }
          String formattedStartTime = _formatTime(shift['startTime']);
          String formattedEndTime = _formatTime(shift['endTime']);

          groupedShifts[shiftDate]!.add({
            "shiftType": _determineShiftType(shift['startTime'], shift['endTime']),
            "startTime": shift['startTime'],
            "endTime": shift['endTime'],
            "formattedStartTime": formattedStartTime,
            "formattedEndTime": formattedEndTime,
            // Optionally include additional data such as doctor details.
          });
        }

        setState(() {
          _allShiftData = groupedShifts;
          _isAllLoading = false;
        });
      } else {
        setState(() {
          _allErrorMessage = 'Failed to load All Shifts: ${response.statusCode}';
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

  /// Formats ISO time string to a readable format (e.g., "9:00 AM").
  String _formatTime(String isoTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(isoTimeString).toLocal();
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return isoTimeString;
    }
  }

  /// Determines shift type based on start time.
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  /// Custom calendar builder for day markers.
  Widget _calendarBuilder(BuildContext context, DateTime day, DateTime focusedDay) {
    final today = DateTime.now().dateOnly();
    final isToday = isSameDay(day, today);
    Widget? dayMarker;
    if (isToday) {
      dayMarker = Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ShiftslColors.secondaryColor,
        ),
        width: 8,
        height: 8,
      );
    }
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

  Widget _buildMyShiftsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendar widget for My Shifts tab
          Padding(
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
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _myShiftData[day.dateOnly()] ?? [];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ShiftslColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text("Allocated Shift"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Selected Day: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildMyShiftContent(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAllShiftsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendar widget for All Shifts tab
          Padding(
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
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _allShiftData[day.dateOnly()] ?? [];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ShiftslColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text("Allocated Shift"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Selected Day: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildAllShiftContent(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMyShiftContent() {
    if (_isMyLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_myErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                _myErrorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMyShiftData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final shifts = _myShiftData[_selectedDay.dateOnly()] ?? [];
    if (shifts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("No shift scheduled for this day"),
        ),
      );
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

  Widget _buildAllShiftContent() {
    if (_isAllLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_allErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                _allErrorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchAllShiftData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final shifts = _allShiftData[_selectedDay.dateOnly()] ?? [];
    if (shifts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("No shift scheduled for this day"),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: shifts.map((shift) {
          return SwapCardV2(
            // For all shifts, you might want to display the doctor's name.
            doctorName: "${_user!.firstName} ${_user!.lastName}",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: const Color(0xFFFFFFFF),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                  ),
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

extension DateOnly on DateTime {
  DateTime dateOnly() {
    return DateTime(year, month, day);
  }
}
