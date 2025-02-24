import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  final double hoursWorked = 160.0;
  final double overtime = 12.5;
  final String doctorName = "Dr. Adam Levine";
  final String hospitalName = "King's Hospital";
  final String email = "adam.levine@kingshospital.example.com";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;
    final avatarRadius = screenWidth * 0.15;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundImage:
              const AssetImage('assets/images/doctor_avatar.png'),
            ),
            SizedBox(height: padding),
            Text(
              doctorName,
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
            ),
            Text(hospitalName, style: const TextStyle(color: Colors.grey)),
            SizedBox(height: padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard("Hours Worked", "$hoursWorked hrs", screenWidth),
                _buildInfoCard("Overtime", "$overtime hrs", screenWidth),
              ],
            ),
            SizedBox(height: padding),
            Container(
              padding: EdgeInsets.all(padding),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account Details",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: padding * 0.5),
                  Text("Email: $email"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, double screenWidth) {
    final cardWidth = screenWidth * 0.4;
    final padding = screenWidth * 0.04;
    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: padding * 0.25),
          Text(
            value,
            style: TextStyle(
                color: Colors.blue,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
