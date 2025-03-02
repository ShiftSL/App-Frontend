import 'package:flutter/material.dart';
import '../utils/constants/constants.dart';

class ShiftCard extends StatelessWidget {
  final String timeRange;
  final String shiftType;
  final String status;
  final VoidCallback onTap;

  const ShiftCard({
    Key? key,
    required this.timeRange,
    required this.shiftType,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  Color statusColor(String status) {
    switch (status) {
      case 'Attending':
        return Colors.green;
      case 'Not Attending':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(
            vertical: 8, horizontal: kDefaultPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // We can use titleMedium for headings:
              Text(
                shiftType,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(timeRange),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor(status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Text(status, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
