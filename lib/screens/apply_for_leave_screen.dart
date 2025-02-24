import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApplyForLeaveScreen extends StatefulWidget {
  const ApplyForLeaveScreen({Key? key}) : super(key: key);

  @override
  State<ApplyForLeaveScreen> createState() => _ApplyForLeaveScreenState();
}

class _ApplyForLeaveScreenState extends State<ApplyForLeaveScreen> {
  DateTime _selectedDate = DateTime.now();

  void _applyForLeave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request submitted!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMM d').format(_selectedDate);
    final padding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Leave'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
              },
            ),
            SizedBox(height: padding),
            Text(
              'Selected date: $formattedDate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: padding),
            ElevatedButton(
              onPressed: _applyForLeave,
              child: const Text('Apply for Leave'),
            ),
          ],
        ),
      ),
    );
  }
}
