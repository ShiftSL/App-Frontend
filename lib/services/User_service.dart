import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';

Future<UserModel?> fetchUserByFirebaseUid(String firebaseUid) async {
  final url = Uri.parse(
      'https://kings.backend.shiftsl.com/api/user/firebase/$firebaseUid');
  print("Fetching user data from $url"); // Log the API endpoint
  final response = await http.get(url);
  print("Response status code: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    try {
      final jsonData = json.decode(response.body);
      print("Parsed JSON data: $jsonData");
      return UserModel.fromJson(jsonData);
    } catch (e) {
      print("Error parsing user data: $e");
      return null;
    }
  } else {
    print("Failed to load user data, status code: ${response.statusCode}");
    return null;
  }
}