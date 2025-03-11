import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:shift_sl/widgets/shift_card.dart';
import 'package:shift_sl/widgets/leave_shift_card_v2.dart';
import 'package:table_calendar/table_calendar.dart';

class ShiftManagementScreen extends StatefulWidget {
  ShiftManagementScreen({Key? key}) : super(key: key);
  @override
  _ShiftManagementScreenState createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'My Shifts'),
            Tab(text: 'Schedule'),
          ],
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
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarStyle: CalendarStyle(
              // holidayDecoration:
              //     BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              // selectedDecoration:
              //     BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
              todayDecoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            ),
            holidayPredicate: (day) => day.weekday == DateTime.sunday,
          ),
          const SizedBox(height: 16),
          ShiftCardV2(),
        ],
      ),
    );
  }
}
