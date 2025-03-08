import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Profile',
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
          child: Column(children: [
            Stack(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset('assets/images/doctor_avatar.png'),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: ShiftslColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.camera,
                      color: ShiftslColors.secondaryColor,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ShiftslSizes.defaultSpace),
            Form(
                child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    label: Text('Name'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Iconsax.user),
                    prefixIconColor: ShiftslColors.primaryColor,
                    floatingLabelStyle: TextStyle(
                      color: ShiftslColors.secondaryColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: ShiftslColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text('Email'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                    prefixIconColor: ShiftslColors.primaryColor,
                    floatingLabelStyle: TextStyle(
                      color: ShiftslColors.secondaryColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: ShiftslColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text('ID'),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Iconsax.profile_tick),
                    prefixIconColor: ShiftslColors.primaryColor,
                    floatingLabelStyle: TextStyle(
                      color: ShiftslColors.secondaryColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: ShiftslColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Iconsax.location),
                    prefixIconColor: ShiftslColors.primaryColor,
                    floatingLabelStyle: TextStyle(
                      color: ShiftslColors.secondaryColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: ShiftslColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Ward',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Iconsax.building),
                    prefixIconColor: ShiftslColors.primaryColor,
                    floatingLabelStyle: TextStyle(
                      color: ShiftslColors.secondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),
                SizedBox(
                  width: double.infinity,
                  height: 50,
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
                            fontSize: ShiftslSizes.fontSizeMd)),
                  ),
                ),
              ],
            ))
          ]),
        ),
      ),
    );
  }
}
