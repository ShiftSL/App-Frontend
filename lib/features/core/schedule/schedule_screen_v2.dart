import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../models/user.dart';
import '../../../utils/constants/colors.dart';
import '../../../widgets/leave_shift_card_v2.dart';
import '../../../widgets/swap_card_v2.dart';
import 'tab_item.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  UserModel? _user;
  bool _isMyLoading = true;
  bool _isAllLoading = true;
  String? _myErrorMessage;
  String? _allErrorMessage;

  Map<DateTime, List<Map<String, dynamic>>> _myShiftData = {};
  Map<DateTime, List<Map<String, dynamic>>> _allShiftData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCachedDataAndFetch();
  }

  Future<void> _loadCachedDataAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    // Load cached user data.
    final cachedUser = prefs.getString('doctorData');
    if (cachedUser != null) {
      try {
        _user = UserModel.fromJson(json.decode(cachedUser));
      } catch (_) {}
    }

    // Load cached shifts.
    final myShifts = prefs.getString('myShifts');
    final allShifts = prefs.getString('allShifts');
    if (myShifts != null) _myShiftData = _decodeShifts(myShifts);
    if (allShifts != null) _allShiftData = _decodeShifts(allShifts);

    setState(() {
      _isMyLoading = false;
      _isAllLoading = false;
    });

    // Refresh user data and shifts.
    await _fetchUserAndShifts(firebaseUser.uid);
  }

  Future<void> _fetchUserAndShifts(String firebaseUid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return;

      final res = await http.get(
        Uri.parse("https://kings.backend.shiftsl.com/api/user/firebase/$firebaseUid"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final user = UserModel.fromJson(json.decode(res.body));
        prefs.setString('doctorData', json.encode(user.toJson()));
        if (!mounted) return;
        setState(() => _user = user);
        await _silentReloadShifts();
      }
    } catch (_) {}
  }

  /// If cached shift data is outdated (i.e. not from today), silently reload it.
  Future<void> _silentReloadShifts() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (prefs.getString('lastFetchMyShifts') != today) {
      await _fetchMyShifts(forceRefresh: true, saveDate: true);
    }
    if (prefs.getString('lastFetchAllShifts') != today) {
      await _fetchAllShifts(forceRefresh: true, saveDate: true);
    }
  }

  /// Pull-to-refresh handler: force a refresh (ignoring cached data).
  Future<void> _refreshAll() async {
    await _clearShiftCache();
    await _fetchMyShifts(forceRefresh: true, saveDate: true);
    await _fetchAllShifts(forceRefresh: true, saveDate: true);
  }

  /// Clears shift-related cache keys from SharedPreferences.
  Future<void> _clearShiftCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('myShifts');
    await prefs.remove('allShifts');
    await prefs.remove('lastFetchMyShifts');
    await prefs.remove('lastFetchAllShifts');
  }

  /// Fetch shifts for the current user (my shifts).
  Future<void> _fetchMyShifts({bool forceRefresh = false, bool saveDate = false}) async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    // If not forced and cache exists for today, use cached data.
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastFetch = prefs.getString('lastFetchMyShifts');
    final cachedData = prefs.getString('myShifts');

    if (!forceRefresh && lastFetch == today && cachedData != null) {
      final data = json.decode(cachedData);
      _processMyShifts(data);
      return;
    }

    try {
      setState(() {
        _isMyLoading = true;
        _myErrorMessage = null;
      });

      final res = await http.get(
        Uri.parse("https://kings.backend.shiftsl.com/api/shift/${_user!.id}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final grouped = _groupShiftsByDate(data);
        prefs.setString('myShifts', json.encode(_encodeShifts(grouped)));
        if (saveDate) {
          prefs.setString('lastFetchMyShifts', today);
        }
        if (!mounted) return;
        setState(() {
          _myShiftData = grouped;
          _isMyLoading = false;
        });
      } else {
        throw Exception('Status: ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _myErrorMessage = "Failed to load My Shifts: $e";
        _isMyLoading = false;
      });
    }
  }

  /// Fetch all shifts.
  Future<void> _fetchAllShifts({bool forceRefresh = false, bool saveDate = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastFetch = prefs.getString('lastFetchAllShifts');
    final cachedData = prefs.getString('allShifts');

    if (!forceRefresh && lastFetch == today && cachedData != null) {
      final data = json.decode(cachedData);
      _processAllShifts(data);
      return;
    }

    try {
      setState(() {
        _isAllLoading = true;
        _allErrorMessage = null;
      });

      final res = await http.get(
        Uri.parse("https://kings.backend.shiftsl.com/api/shift"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final grouped = _groupAllShifts(data);
        prefs.setString('allShifts', json.encode(_encodeShifts(grouped)));
        if (saveDate) {
          prefs.setString('lastFetchAllShifts', today);
        }
        setState(() {
          _allShiftData = grouped;
          _isAllLoading = false;
        });
      } else {
        throw Exception('Status: ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allErrorMessage = "Failed to load All Shifts: $e";
        _isAllLoading = false;
      });
    }
  }

  /// Group my shifts by date with the shift id.
  Map<DateTime, List<Map<String, dynamic>>> _groupShiftsByDate(List data) {
    final result = <DateTime, List<Map<String, dynamic>>>{};
    for (var shift in data) {
      final date = DateTime.parse(shift['startTime']).toLocal().dateOnly();
      result.putIfAbsent(date, () => []).add({
        "id": shift["id"], // shift id
        "shiftType": _determineShiftType(shift['startTime']),
        "startTime": shift['startTime'],
        "endTime": shift['endTime'],
        "formattedStartTime": _formatTime(shift['startTime']),
        "formattedEndTime": _formatTime(shift['endTime']),
      });
    }
    return result;
  }

  /// Group all shifts by date with the shift id.
  Map<DateTime, List<Map<String, dynamic>>> _groupAllShifts(List data) {
    final result = <DateTime, List<Map<String, dynamic>>>{};
    for (var shift in data) {
      final date = DateTime.parse(shift['startTime']).toLocal().dateOnly();
      final shiftType = _determineShiftType(shift['startTime']);
      final formattedStart = _formatTime(shift['startTime']);
      final formattedEnd = _formatTime(shift['endTime']);

      final doctors = shift['doctors'] as List? ?? [];

      if (doctors.isEmpty) {
        // Unassigned shift.
        result.putIfAbsent(date, () => []).add({
          "id": shift["id"],
          "shiftType": shiftType,
          "startTime": shift['startTime'],
          "endTime": shift['endTime'],
          "formattedStartTime": formattedStart,
          "formattedEndTime": formattedEnd,
          "doctorNames": "Unassigned",
        });
      } else {
        for (var doc in doctors) {
          final doctorName = "${doc['firstName']} ${doc['lastName']}";
          result.putIfAbsent(date, () => []).add({
            "id": shift["id"],
            "shiftType": shiftType,
            "startTime": shift['startTime'],
            "endTime": shift['endTime'],
            "formattedStartTime": formattedStart,
            "formattedEndTime": formattedEnd,
            "doctorNames": doctorName,
          });
        }
      }
    }
    return result;
  }

  String _determineShiftType(String start) {
    final hour = int.tryParse(start.split('T')[1].split(':')[0]) ?? 0;
    if (hour < 12) return "Morning Shift";
    if (hour < 18) return "Day Shift";
    return "Night Shift";
  }

  String _formatTime(String iso) =>
      DateFormat('h:mm a').format(DateTime.parse(iso).toLocal());

  Map<String, dynamic> _encodeShifts(Map<DateTime, List<Map<String, dynamic>>> map) =>
      map.map((k, v) => MapEntry(k.toIso8601String(), v));

  Map<DateTime, List<Map<String, dynamic>>> _decodeShifts(String raw) {
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(
        DateTime.parse(k),
        List<Map<String, dynamic>>.from(v.map((e) => Map<String, dynamic>.from(e)))));
  }

  /// Process my shifts data (used by _fetchMyShifts).
  void _processMyShifts(List<dynamic> data) {
    final grouped = _groupShiftsByDate(data);
    setState(() {
      _myShiftData = grouped;
    });
  }

  /// Process all shifts data (used by _fetchAllShifts).
  void _processAllShifts(List<dynamic> data) {
    final grouped = _groupAllShifts(data);
    setState(() {
      _allShiftData = grouped;
    });
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(_selectedDay, selected)) {
      setState(() {
        _selectedDay = selected;
        _focusedDay = focused;
      });
    }
  }

  /// Build the TableCalendar widget.
  Widget _buildCalendar(Map<DateTime, List<Map<String, dynamic>>> shiftData, bool isScheduleView) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) =>
              _calendarBuilder(context, day, focusedDay, shiftData, isScheduleView),
          markerBuilder: (context, day, events) => const SizedBox.shrink(),
        ),
        focusedDay: _focusedDay,
        selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
        onDaySelected: _onDaySelected,
        calendarFormat: _calendarFormat,
        onFormatChanged: (f) => setState(() => _calendarFormat = f),
        onPageChanged: (fd) => _focusedDay = fd,
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 50,
        eventLoader: (d) => shiftData[d.dateOnly()] ?? [],
        availableGestures: AvailableGestures.all,
      ),
    );
  }

  /// Custom calendar cell builder.
  Widget _calendarBuilder(BuildContext context, DateTime day, DateTime focusedDay,
      Map<DateTime, List<Map<String, dynamic>>> shiftData, bool isScheduleView) {
    final isToday = isSameDay(day, DateTime.now().dateOnly());
    final isSelected = isSameDay(day, _selectedDay);
    final date = day.dateOnly();

    if (_user == null || shiftData.isEmpty) {
      return _defaultDayCell(day, isToday, isSelected);
    }

    List<Map<String, dynamic>> shifts = shiftData[date] ?? [];
    if (isScheduleView) {
      shifts = shifts.where((s) =>
      s['doctorNames'] == '${_user!.firstName} ${_user!.lastName}').toList();
    }

    final dots = shifts.map((shift) {
      Color dotColor;
      switch (shift['shiftType']) {
        case "Morning Shift":
          dotColor = Colors.orange;
          break;
        case "Day Shift":
          dotColor = Colors.blue;
          break;
        case "Night Shift":
          dotColor = Colors.deepPurple;
          break;
        default:
          dotColor = Colors.grey;
      }
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: isSelected
          ? const BoxDecoration(color: Colors.black12, shape: BoxShape.circle)
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${day.day}',
              style: isToday
                  ? const TextStyle(
                color: ShiftslColors.primaryColor,
                fontWeight: FontWeight.bold,
              )
                  : null),
          if (dots.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dots.length > 3 ? dots.sublist(0, 3) : dots,
              ),
            ),
        ],
      ),
    );
  }

  Widget _defaultDayCell(DateTime day, bool isToday, bool isSelected) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: isSelected
          ? const BoxDecoration(color: Colors.black12, shape: BoxShape.circle)
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
        ],
      ),
    );
  }

  /// Builds the tab view that shows the calendar, legend, and shift list.
  Widget _buildTab({
    required bool isLoading,
    required String? error,
    required Map<DateTime, List<Map<String, dynamic>>> data,
    required Future<void> Function() onRefresh,
    required Widget Function(List<Map<String, dynamic>>) builder,
    required bool isScheduleView,
  }) {
    final events = data[_selectedDay.dateOnly()] ?? [];
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          _buildCalendar(data, isScheduleView),
          buildShiftLegend(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Selected Day: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            _buildError(error, onRefresh)
          else if (events.isEmpty)
              _buildEmpty("No shifts on this day")
            else
              builder(events),
        ],
      ),
    );
  }

  Widget _buildError(String msg, VoidCallback retry) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        const Icon(Icons.error, size: 32, color: Colors.red),
        const SizedBox(height: 10),
        Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: retry, child: const Text("Retry")),
      ],
    ),
  );

  Widget _buildEmpty(String msg) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(child: Text(msg)),
  );

  /// Builder for "My Shifts" tab.
  Widget _myShiftsBuilder(List<Map<String, dynamic>> data) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: data
          .map<Widget>((shift) => LeaveShiftCardV2(
        shiftType: shift["shiftType"],
        startTime: shift["startTime"],
        endTime: shift["endTime"],
        formattedStartTime: shift["formattedStartTime"],
        formattedEndTime: shift["formattedEndTime"],
        selectedDate: _selectedDay,
        shiftID: shift["id"] ?? 0,
        doctorID: _user!.id,
      ))
          .toList(),
    ),
  );

  /// Builder for "Schedule View" tab.
  Widget _allShiftsBuilder(List<Map<String, dynamic>> data) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: data
          .map<Widget>((shift) => SwapCardV2(
        doctorName: shift["doctorNames"],
        shiftType: shift["shiftType"],
        startTime: shift["startTime"],
        endTime: shift["endTime"],
        formattedStartTime: shift["formattedStartTime"],
        formattedEndTime: shift["formattedEndTime"],
        selectedDate: _selectedDay,
      ))
          .toList(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule', style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const BoxDecoration(
                  color: ShiftslColors.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                dividerColor: Colors.transparent,
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
          // My Shifts Tab.
          _buildTab(
            isLoading: _isMyLoading,
            error: _myErrorMessage,
            data: _myShiftData,
            onRefresh: () => _fetchMyShifts(forceRefresh: true, saveDate: true),
            builder: _myShiftsBuilder,
            isScheduleView: false,
          ),
          // Schedule View Tab.
          _buildTab(
            isLoading: _isAllLoading,
            error: _allErrorMessage,
            data: _allShiftData,
            onRefresh: () => _fetchAllShifts(forceRefresh: true, saveDate: true),
            builder: _allShiftsBuilder,
            isScheduleView: true,
          ),
        ],
      ),
    );
  }
}

/// Builds a legend for shift types.
Widget buildShiftLegend() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _LegendDot(color: Colors.orange, label: "Morning Shift"),
        _LegendDot(color: Colors.blue, label: "Day Shift"),
        _LegendDot(color: Colors.deepPurple, label: "Night Shift"),
      ],
    ),
  );
}

/// A small widget for a colored dot with a label.
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

extension DateOnly on DateTime {
  DateTime dateOnly() => DateTime(year, month, day);
}
