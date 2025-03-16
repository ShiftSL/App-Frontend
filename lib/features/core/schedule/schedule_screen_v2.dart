import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/features/core/schedule/tab_item.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
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
                    offset: Offset(0, 1),
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
          LeaveShiftCardV2(),
        ],
      ),
    );
  }
}
