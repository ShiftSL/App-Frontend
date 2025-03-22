import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/features/core/schedule/schedule_screen_v2.dart';
import 'package:shift_sl/screens/notification_screen.dart';
import 'package:shift_sl/screens/schedule_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:shift_sl/widgets/leave_shift_card_v2.dart';
import 'package:shift_sl/models/shift.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A mock shift item structure for “Today’s Schedule”

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Image.asset(
          'assets/images/shift_sl_logo.png',
          height: 100,
          width: 120,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            onPressed: () => Get.to(() => const NotificationScreen()),
            icon: const Icon(Iconsax.notification_bing5),
            color: ShiftslColors.primaryColor,
            iconSize: 30,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Greeting Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShiftslColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage('assets/images/doctor_profile.jpg'),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Hello!',
                          style: TextStyle(
                            color: ShiftslColors.white,
                            fontSize: ShiftslSizes.fontSizeMd,
                            fontWeight: FontWeight.w400,
                          )),
                      SizedBox(height: 4),
                      Text(
                        'Dr. Adam Levine',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ShiftslSizes.fontSizeLg,
                          color: ShiftslColors.white,
                        ),
                      ),
                      Text('King’s Hospital',
                          style: TextStyle(
                              color: ShiftslColors.secondaryColor,
                              fontSize: ShiftslSizes.fontSizeMd,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: ShiftslSizes.defaultSpace),

            // schdule published card
            Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShiftslColors.primaryColor,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    'New Schedule Published!',
                    style: TextStyle(
                      color: ShiftslColors.white,
                      fontSize: ShiftslSizes.fontSizeMd,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 130,
                    height: 50,
                    child: FilledButton(
                      onPressed: () => Get.to(() => const ScheduleScreen()),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        backgroundColor: ShiftslColors.secondaryColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        side: BorderSide.none,
                      ),
                      child: const Text(
                        'View Schedule',
                        style: TextStyle(
                            color: ShiftslColors.primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: ShiftslSizes.fontSizeMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ShiftslSizes.defaultSpace),

            // "Today's Schedule"
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Next Shift",
                  style: TextStyle(
                    color: ShiftslColors.primaryColor,
                    fontSize: ShiftslSizes.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Build "today" shift card
            // _buildShiftCard(todaysShift),
            // LeaveShiftCardV2(),
            const SizedBox(height: 10),
            // "Upcoming Shifts"
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Upcoming Shifts",
                  style: TextStyle(
                    color: ShiftslColors.primaryColor,
                    fontSize: ShiftslSizes.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
