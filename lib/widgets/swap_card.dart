import 'package:flutter/material.dart';
import '../utils/constants/constants.dart';

class SwapCard extends StatelessWidget {
  final String name;
  final String role;
  final String date;
  final String time;
  final String shiftType;
  final String status;
  final VoidCallback onActionPressed;

  const SwapCard({
    Key? key,
    required this.name,
    required this.role,
    required this.date,
    required this.time,
    required this.shiftType,
    required this.status,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(kDefaultPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name - $role',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(date, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('$time ($shiftType)'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status: $status'),
                ElevatedButton(
                  onPressed: onActionPressed,
                  child: const Text('Request Swap'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
