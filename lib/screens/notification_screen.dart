import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> notifications = const [
    {
      'title': 'New Swap Request',
      'subtitle': 'Dr. John Doe requests to swap shift with you.',
      'date': 'Today',
      'type': 'swap',
    },
    {
      'title': 'Shift Swap Approved',
      'subtitle': 'Your shift swap request was approved.',
      'date': 'Yesterday',
      'type': 'swap',
    },
    {
      'title': 'General Announcement',
      'subtitle': 'The cafeteria will be closed tomorrow.',
      'date': 'Today',
      'type': 'info',
    },
    {
      'title': 'Schedule Reminder',
      'subtitle': 'Don’t forget to update your shifts for tomorrow.',
      'date': 'Yesterday',
      'type': 'info',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;
    final swapNotifications =
    notifications.where((notif) => notif['type'] == 'swap').toList();
    final otherNotifications =
    notifications.where((notif) => notif['type'] != 'swap').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (swapNotifications.isNotEmpty) ...[
              const Text(
                'Swap Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: padding),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: swapNotifications.length,
                separatorBuilder: (context, index) => SizedBox(height: padding),
                itemBuilder: (context, index) {
                  final item = swapNotifications[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.swap_calls, color: Colors.white),
                      ),
                      title: Text(item['title'] ?? ''),
                      subtitle: Text(item['subtitle'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Swap request approved.')),
                              );
                            },
                            child: const Text('Approve'),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Swap request denied.')),
                              );
                            },
                            child: const Text('Deny'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: padding * 1.5),
            ],
            if (otherNotifications.isNotEmpty) ...[
              const Text(
                'Other Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: padding),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: otherNotifications.length,
                separatorBuilder: (context, index) => SizedBox(height: padding),
                itemBuilder: (context, index) {
                  final item = otherNotifications[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.info, color: Colors.white),
                      ),
                      title: Text(item['title'] ?? ''),
                      subtitle: Text(item['subtitle'] ?? ''),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
