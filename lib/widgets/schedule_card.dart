import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String shift;
  final String date;
  final String time;
  final String status;
  final Color color;

  const ScheduleCard({
    Key? key,
    required this.shift,
    required this.date,
    required this.time,
    required this.status,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.wb_sunny, color: Colors.orange),
        title: Text(shift),
        subtitle: Text("$date\n$time"),
        trailing: Chip(
          label: Text(status),
          backgroundColor: color,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
