import 'package:flutter/material.dart';
import '../widgets/swap_card.dart';

class SwapsScreen extends StatelessWidget {
  const SwapsScreen({super.key});

  final List<Map<String, String>> swaps = const [
    {
      'name': 'Dr. John Doe',
      'role': 'Neurologist',
      'date': 'Monday, 10th December', // mock data point
      'time': '1:00 PM - 7:00 PM',      // mock data point
      'shiftType': 'Day',
      'status': 'Available'
    },
    {
      'name': 'Nurse Emily',
      'role': 'Pediatric Nurse',
      'date': 'Monday, 10th December', // mock data point
      'time': '7:00 AM - 1:00 PM',      // mock data point
      'shiftType': 'Morning',
      'status': 'Pending'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap Requests'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: ListView.builder(
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return SwapCard(
              name: swap['name'] ?? '',
              role: swap['role'] ?? '',
              date: swap['date'] ?? '',
              time: swap['time'] ?? '',
              shiftType: swap['shiftType'] ?? '',
              status: swap['status'] ?? '',
              onActionPressed: () {},
            );
          },
        ),
      ),
    );
  }
}
