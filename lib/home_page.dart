import 'package:flutter/material.dart';
import 'widgets/schedule_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("shiftSL"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      AssetImage('assets/avatar.png'), // Placeholder
                ),
                const SizedBox(width: 16),
                const Text(
                  "Hello!\nDr. Adam Levine\nKing's Hospital",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Today's Schedule",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const ScheduleCard(
              shift: "WARD 3",
              date: "Monday, 10th December",
              time: "9:00 AM",
              status: "Attending",
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              "Upcoming Shifts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const ScheduleCard(
              shift: "WARD 3",
              date: "Monday, 11th December",
              time: "7:00 PM",
              status: "Not Attending",
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
