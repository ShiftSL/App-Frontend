import 'package:flutter/material.dart';
import 'package:shift_sl/features/core/schedule/tab_item.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

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
    final TabController _tabController =
        TabController(length: 3, vsync: Scaffold.of(context));

    // Filter notifications by type
    final swapNotifications =
        notifications.where((notif) => notif['type'] == 'swap').toList();
    final claimNotifications =
        notifications.where((notif) => notif['type'] == 'claim').toList();
    final generalNotifications =
        notifications.where((notif) => notif['type'] == 'general').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: const Color(0xFFFFFFFF),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: const BoxDecoration(
                  color: ShiftslColors.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: ShiftslColors.primaryColor,
                tabs: const [
                  TabItem(title: 'Shift Swap'),
                  TabItem(title: 'Claim Shift'),
                  TabItem(title: 'General')
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Shift Swap Tab
          _shiftSwapView(
              padding: padding, swapNotifications: swapNotifications),
          // Claim Shift Tab
          _claimShiftView(
              padding: padding, claimNotifications: claimNotifications),
          // General Notification Tab
          _generalNotificationView(
              padding: padding, generalNotifications: generalNotifications),
        ],
      ),
    );
  }
}

class _generalNotificationView extends StatelessWidget {
  const _generalNotificationView({
    super.key,
    required this.padding,
    required this.generalNotifications,
  });

  final double padding;
  final List<Map<String, String>> generalNotifications;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: generalNotifications.length,
        separatorBuilder: (context, index) => SizedBox(height: padding),
        itemBuilder: (context, index) {
          final item = generalNotifications[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF79C3FF),
                child: Icon(Iconsax.calendar, color: Colors.white),
              ),
              title: Text(item['title'] ?? ''),
              subtitle: Text(item['subtitle'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}

class _claimShiftView extends StatelessWidget {
  const _claimShiftView({
    super.key,
    required this.padding,
    required this.claimNotifications,
  });

  final double padding;
  final List<Map<String, String>> claimNotifications;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: claimNotifications.length,
        separatorBuilder: (context, index) => SizedBox(height: padding),
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
                child: Icon(Iconsax.calendar_edit, color: Colors.white),
              ),
              title: Text(
                item['title'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
    );
  }
}

class _shiftSwapView extends StatelessWidget {
  const _shiftSwapView({
    super.key,
    required this.padding,
    required this.swapNotifications,
  });

  final double padding;
  final List<Map<String, String>> swapNotifications;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: ListView.separated(
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
                child: Icon(Iconsax.arrow_swap_horizontal, color: Colors.white),
              ),
              title: Text(item['title'] ?? ''),
              subtitle: Text(item['subtitle'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Swap request approved.')),
                      );
                    },
                    child: const Text('Approve'),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Swap request denied.')),
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
    );
  }
}
