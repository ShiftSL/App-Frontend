import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String shiftType;
  final String ward;
  final String date;
  final String time;
  final String status;
  final Color statusColor;

  const ScheduleCard({
    Key? key,
    required this.shiftType,
    required this.ward,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      
      child: ListTile(
        leading: Icon(
          shiftType == 'Morning'
              ? Icons.wb_sunny
              : shiftType == 'Night'
              ? Icons.nights_stay
              : Icons.sunny,
          color: shiftType == 'Morning'
              ? Colors.orange
              : shiftType == 'Night'
              ? Colors.blue
              : Colors.yellow,
        ),
        title: Text(ward),
        subtitle: Text("$date\n$time"),
        trailing: Chip(
          label: Text(status),
          backgroundColor: statusColor,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
