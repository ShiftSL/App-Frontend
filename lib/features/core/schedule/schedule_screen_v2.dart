import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/features/core/schedule/tab_item.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:shift_sl/widgets/leave_shift_card_v2.dart';
import 'package:shift_sl/widgets/swap_card_v2.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shift_sl/features/core/schedule/widgets/my_shift_tab.dart';

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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Map<String, dynamic>>> _shiftData =
      {}; // Shifts grouped by date
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchShiftData(); // Fetch all shift data
  }

  // Fetch all shift data from the API
  Future<void> _fetchShiftData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://spring-app-284647065201.us-central1.run.app/api/shift/14'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Group shifts by date
        final Map<DateTime, List<Map<String, dynamic>>> groupedShifts = {};
        for (var shift in data) {
          DateTime shiftDate =
              DateTime.parse(shift['startTime']).toLocal().dateOnly();
          if (!groupedShifts.containsKey(shiftDate)) {
            groupedShifts[shiftDate] = [];
          }

          // Format the start and end times
          String formattedStartTime = _formatTime(shift['startTime']);
          String formattedEndTime = _formatTime(shift['endTime']);

          groupedShifts[shiftDate]!.add({
            "shiftType":
                _determineShiftType(shift['startTime'], shift['endTime']),
            "startTime": shift['startTime'],
            "endTime": shift['endTime'],
            "formattedStartTime": formattedStartTime,
            "formattedEndTime": formattedEndTime,
          });
        }

        setState(() {
          _shiftData = groupedShifts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load shift data: ${response.statusCode}';
          _isLoading = false;
          _shiftData = {};
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching shift data: $e';
        _isLoading = false;
        _shiftData = {};
      });
    }
  }

  // Format time from ISO string to readable format (e.g., "9:00 AM")
  String _formatTime(String isoTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(isoTimeString).toLocal();
      return DateFormat('h:mm a').format(dateTime); // e.g., "9:00 AM"
    } catch (e) {
      return isoTimeString; // Return original string if parsing fails
    }
  }

  // Helper method to determine shift type based on start and end times
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

  // Custom calendar builder for day markers
  Widget _calendarBuilder(
      BuildContext context, DateTime day, DateTime focusedDay) {
    // Check if there's a shift on this day
    final today = DateTime.now().dateOnly();
    final hasShift = _shiftData.containsKey(day.dateOnly());
    final isToday = isSameDay(day, today);
    final isSelected = isSameDay(day, _selectedDay);

    // Standard container
    Widget? dayMarker;

    if (hasShift) {
      if (isToday) {
        // Today's shift - filled green circle
        dayMarker = Container(
          margin: const EdgeInsets.all(.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ShiftslColors.secondaryColor,
          ),
          width: 8,
          height: 8,
        );
      }
    }

    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: isSelected
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

  Widget _buildMyShiftsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
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
                // This helps the calendar know which days have events
                return _shiftData[day.dateOnly()] ?? [];
              },
            ),
          ),

          // Calendar Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Today's shift legend
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
                const SizedBox(width: 20),
                // Allocated shift legend
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Selected Day: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
                // This helps the calendar know which days have events
                return _shiftData[day.dateOnly()] ?? [];
              },
            ),
          ),

          // Calendar Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Today's shift legend
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
                const SizedBox(width: 20),
                // Allocated shift legend
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Selected Day: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildAllShiftContent(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMyShiftContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchShiftData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final shifts = _shiftData[_selectedDay.dateOnly()] ?? [];

    if (shifts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("No shift scheduled for this day"),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
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
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchShiftData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final shifts = _shiftData[_selectedDay.dateOnly()] ?? [];

    if (shifts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("No shift scheduled for this day"),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: shifts.map((shift) {
          return SwapCardV2(
            doctorName: shift["docterName"],
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
}

extension DateOnly on DateTime {
  DateTime dateOnly() {
    return DateTime(year, month, day);
  }
}
