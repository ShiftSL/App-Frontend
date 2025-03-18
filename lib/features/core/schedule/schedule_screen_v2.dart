import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/features/core/schedule/tab_item.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:shift_sl/widgets/leave_shift_card_v2.dart';
import 'package:table_calendar/table_calendar.dart';

/// Mock JSON data for shifts.
/// Keys are dates in yyyy-MM-dd format.
/// Note: We no longer include "startHour" in the JSON.
/// Instead, we derive it from the shift type.
final Map<String, List<Map<String, String>>> mockShifts = {
  '2025-02-20': [
    {
      'timeLabel': 'Morning',
      'timeRange': '7:00 AM - 01:00 Noon',
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
  '2025-03-10': [
    {
      'timeLabel': 'Morning',
      'timeRange': '7:00 AM - 1:00 PM',
      'status': 'Leave',
    },
  ],
};

/// Helper function that returns the start hour (0-23) based on shift type.
int getStartHour(String shiftType) {
  switch (shiftType.toLowerCase()) {
    case 'morning':
      return 7;
    case 'day':
      return 13;
    case 'night':
      return 19;
    default:
      return 0;
  }
}

class ShiftManagementScreen extends StatefulWidget {
  ShiftManagementScreen({Key? key}) : super(key: key);
  @override
  _ShiftManagementScreenState createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime today = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  void _onDaySelected(DateTime Day, DateTime focusedDay) {
    setState(() {
      today = Day;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          Center(child: Text('Schedule View Placeholder')),
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
            child: Container(
              child: TableCalendar(
                locale: 'en_US',
                rowHeight: 50,
                focusedDay: today,
                startingDayOfWeek: StartingDayOfWeek.monday,
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, today),
                onDaySelected: _onDaySelected,
                calendarFormat: _calendarFormat,
                //format change
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  today = focusedDay;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Selected Day : ${today.toString().split(" ")[0]}'),
          LeaveShiftCardV2(),
        ],
      ),
    );
  }
}
