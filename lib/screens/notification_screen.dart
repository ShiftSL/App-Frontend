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
      'title': 'Open Shift Available',
      'subtitle': 'A shift is open due to a colleague\'s leave. Claim it now!',
      'date': 'Today',
      'type': 'claim',
    },
    {
      'title': 'Shift Reminder',
      'subtitle': 'Don’t forget to update your shifts for tomorrow.',
      'date': 'Yesterday',
      'type': 'general',
    },
    {
      'title': 'General Announcement',
      'subtitle': 'The cafeteria will be closed tomorrow.',
      'date': 'Today',
      'type': 'general',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;

    // Filter notifications by type
    final swapNotifications =
    notifications.where((notif) => notif['type'] == 'swap').toList();
    final claimNotifications =
    notifications.where((notif) => notif['type'] == 'claim').toList();
    final generalNotifications =
    notifications.where((notif) => notif['type'] == 'general').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Shift Swap'),
              Tab(text: 'Claim Shift'),
              Tab(text: 'General'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Shift Swap Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: swapNotifications.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: padding),
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
            ),
            // Claim Shift Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: claimNotifications.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: padding),
                itemBuilder: (context, index) {
                  final item = claimNotifications[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.assignment_turned_in, color: Colors.white),
                      ),
                      title: Text(item['title'] ?? ''),
                      subtitle: Text(item['subtitle'] ?? ''),
                      trailing: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Shift claimed.')),
                          );
                        },
                        child: const Text('Claim'),
                      ),
                    ),
                  );
                },
              ),
            ),
            // General Notification Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: generalNotifications.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: padding),
                itemBuilder: (context, index) {
                  final item = generalNotifications[index];
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
            ),
          ],
        ),
      ),
    );
  }
}
