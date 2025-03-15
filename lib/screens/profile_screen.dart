import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/screens/edit_profile_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  final double hoursWorked = 160.0;
  final double overtime = 12.5;
  final String doctorName = "Dr. Adam Levine";
  final String hospitalName = "King's Hospital";
  final String email = "adamlevine@kingshospital.example.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(ShiftslSizes.defaultSpace),
            child: Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset('assets/images/doctor_profile.jpg'),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  doctorName,
                  style: TextStyle(
                    fontSize: ShiftslSizes.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: ShiftslSizes.fontSizeMd,
                    color: const Color(0xFF131313),
                  ),
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const EditProfileScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ShiftslColors.primaryColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      side: BorderSide.none,
                    ),
                    child: const Text('Edit Profile',
                        style: TextStyle(
                          color: ShiftslColors.secondaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: ShiftslSizes.fontSizeMd,
                        )),
                  ),
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),
                const Divider(
                  color: ShiftslColors.darkGrey,
                  thickness: 0.2,
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),

                //Menu
                ProfileMenu(
                  title: 'Schedule',
                  icon: Iconsax.calendar,
                  onpress: () {},
                ),
                ProfileMenu(
                  title: 'Swap Requests',
                  icon: Iconsax.arrow_swap_horizontal,
                  onpress: () {},
                ),
                ProfileMenu(
                  title: 'Leave Requests',
                  icon: Iconsax.cloud_lightning,
                  onpress: () {},
                ),
                ProfileMenu(
                  title: 'Leave Report',
                  icon: Iconsax.receipt,
                  onpress: () {},
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),
                const Divider(
                  color: ShiftslColors.darkGrey,
                  thickness: 0.2,
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),
                ProfileMenu(
                  title: 'Help Center',
                  icon: Iconsax.message_question,
                  onpress: () {},
                ),
                ProfileMenu(
                  title: 'Logout',
                  icon: Iconsax.logout,
                  textColor: Colors.red,
                  onpress: () {},
                ),
              ],
            ),
          ),
        ));
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.title,
    required this.icon,
    required this.onpress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onpress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onpress,
      leading: Container(
        width: 50,
        height: 40,
        decoration: BoxDecoration(
          color: ShiftslColors.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: ShiftslColors.secondaryColor,
        ),
      ),
      title: Text(title,
          style: TextStyle(
            color: textColor ?? const Color(0xFF131313),
            fontSize: ShiftslSizes.fontSizeMd,
            fontWeight: FontWeight.w400,
          )),
      trailing: const Icon(Iconsax.arrow_right_3, color: Colors.grey),
    );
  }
}
