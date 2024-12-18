import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widgets/schedule_card.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Schedule"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarStyle: const CalendarStyle(
              todayDecoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 20),
          const ScheduleCard(
            shift: "WARD 3",
            date: "Thursday, 8th November",
            time: "8:00 AM",
            status: "Attending",
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          const ScheduleCard(
            shift: "WARD 3",
            date: "Friday, 9th November",
            time: "2:00 PM",
            status: "Pending",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}
