import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
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
        title: DropdownButton<String>(
          value: 'Ward 01',
          items: ['Ward 01', 'Ward 02', 'Ward 03']
              .map((ward) => DropdownMenuItem(value: ward, child: Text(ward)))
              .toList(),
          onChanged: (value) {},
        ),
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
          ShiftCard(),
        ],
      ),
    );
  }
}

class ShiftCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
      child: Card(
        color: ShiftslColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, color: ShiftslColors.secondaryColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dr. Adam Levine',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => const EditProfileScreen()),
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
                  'Apply for Leave',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Iconsax.calendar, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Monday, 26 Jan',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Spacer(),
                  Icon(Iconsax.clock, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    '07:00 - 13:00',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
