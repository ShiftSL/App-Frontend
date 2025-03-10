import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';

class ShiftCardV2 extends StatelessWidget {
  const ShiftCardV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Card(
        color: ShiftslColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, color: ShiftslColors.secondaryColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dr. Adam Levine',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => const EditProfileScreen()),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        backgroundColor: ShiftslColors.secondaryColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        side: BorderSide.none,
                      ),
                      child: const Icon(
                        Iconsax.calendar_add,
                        size: 24,
                        color: ShiftslColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const SizedBox(
                height: 20,
                width: double.infinity,
                child: Text(
                  'Apply for Leave',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Iconsax.calendar, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Monday, 26 Jan',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Spacer(),
                  Icon(Iconsax.clock, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    '07:00 - 13:00',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
