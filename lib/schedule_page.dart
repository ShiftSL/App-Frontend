import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/schedule_card.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Schedule",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Calendar Widget
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Today's Schedule Card
          const ScheduleCard(
            shiftType: "Morning",
            ward: "WARD 3",
            date: "Thursday, 8th November",
            time: "8:00 AM",
            status: "Attending",
            statusColor: Colors.green,
          ),
          const SizedBox(height: 10),

          // Upcoming Schedule Card
          const ScheduleCard(
            shiftType: "Day",
            ward: "WARD 3",
            date: "Friday, 9th November",
            time: "2:00 PM",
            status: "Pending",
            statusColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
