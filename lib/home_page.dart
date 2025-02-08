
import 'package:flutter/material.dart';
import '../widgets/profile_card.dart';
import '../widgets/notification_card.dart';
import '../widgets/schedule_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "ShiftSL",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 5,
          iconTheme: const IconThemeData(color: Colors.black),

        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: ProfileCard(),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.green,
                      size: 60,
                    ),
                    onPressed: () {
                      // Notification action
                    },
                  ),
                ),
              ],
            ),
              const Text(
                "Today's Schedule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ScheduleCard(
                time: '6.00 am',
                shiftType: 'Morning',
                ward: 'WARD 3',
                date: 'Monday, 10th December',
                status: 'Attending',
                statusColor: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                "Upcoming Shifts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ScheduleCard(
                time: '7.00 pm',
                shiftType: 'Night',
                ward: 'WARD 3',
                date: 'Monday, 11th December',
                status: 'Not Attending',
                statusColor: Colors.red,
              ),
              const SizedBox(height: 10),
              ScheduleCard(
                time: '12.00 pm',
                shiftType: 'Day',
                ward: 'WARD 3',
                date: 'Monday, 12th December',
                status: 'Pending',
                statusColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}