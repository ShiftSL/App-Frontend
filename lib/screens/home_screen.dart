import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A mock shift item structure for “Today’s Schedule”
  Map<String, dynamic> todaysShift = {
    'timeLabel': 'Morning',
    'ward': 'WARD 3',
    'date': 'Monday, 10th December',
    'time': '6.00 am',
    'status': 'Attending', // or "Not Attending" / "Pending"
  };

  // A mock list for “Upcoming Shifts”
  List<Map<String, dynamic>> upcomingShifts = [
    {
      'timeLabel': 'Night',
      'ward': 'WARD 3',
      'date': 'Monday, 11th December',
      'time': '7.00 pm',
      'status': 'Not Attending',
    },
    {
      'timeLabel': 'Day',
      'ward': 'WARD 3',
      'date': 'Monday, 12th December',
      'time': '12.00 pm',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 120,
        title: Image.asset(
          'assets/images/shift_sl_logo.png',
          height: 180,
        ),
        centerTitle: true,

      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Greeting Card
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.only(left: 16, top: 25, right: 16, bottom: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/doctor_avatar.png'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Hello!', style: TextStyle(color: Colors.green)),
                      SizedBox(height: 4),
                      Text(
                        'Dr. Adam Levine',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text('King’s Hospital', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // "Today's Schedule"
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today’s Schedule",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            // Build "today" shift card
            _buildShiftCard(todaysShift),

            const SizedBox(height: 24),
            // "Upcoming Shifts"
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Upcoming Shifts",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            // Build upcoming shift cards
            Column(
              children: upcomingShifts.map((shift) => _buildShiftCard(shift)).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build a shift card with an onTap to show status dialog
  Widget _buildShiftCard(Map<String, dynamic> shiftData) {
    final String timeLabel = shiftData['timeLabel'] ?? 'Shift';
    final String ward = shiftData['ward'] ?? 'WARD';
    final String date = shiftData['date'] ?? 'Date';
    final String time = shiftData['time'] ?? 'Time';
    final String status = shiftData['status'] ?? 'Pending';

    // Decide the color based on status
    Color statusColor;
    switch (status) {
      case 'Attending':
        statusColor = Colors.green;
        break;
      case 'Not Attending':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blueGrey;
    }

    // Decide the icon based on timeLabel
    String iconPath;
    if (timeLabel.toLowerCase().contains('morning')) {
      iconPath = 'assets/icons/morning.png';
    } else if (timeLabel.toLowerCase().contains('night')) {
      iconPath = 'assets/icons/half-moon.png';
    } else {
      iconPath = 'assets/icons/sun.png';
    }

    return GestureDetector(
      onTap: () => _showStatusDialog(shiftData),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: Colors.white,
              child: Image.asset(
                iconPath,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            // Shift info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timeLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '$ward\n$date\n$time',
                    style: const TextStyle(color: Colors.grey, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show a dialog to update status (Attending / Not Attending)
  void _showStatusDialog(Map<String, dynamic> shiftData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Shift Status'),
          content: const Text('Are you attending this shift?'),
          actions: [
            TextButton(
              onPressed: () {
                _updateShiftStatus(shiftData, 'Attending');
                Navigator.pop(context);
              },
              child: const Text('Attending'),
            ),
            TextButton(
              onPressed: () {
                _updateShiftStatus(shiftData, 'Not Attending');
                Navigator.pop(context);
              },
              child: const Text('Not Attending'),
            ),
          ],
        );
      },
    );
  }

  // Update the shift's 'status' and refresh the UI
  void _updateShiftStatus(Map<String, dynamic> shiftData, String newStatus) {
    setState(() {
      shiftData['status'] = newStatus;
    });
  }
}
