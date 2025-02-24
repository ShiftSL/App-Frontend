import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/shift_model.dart';

class ShiftService {
  // Example fetch from an API
  static Future<List<Shift>> fetchShifts() async {
    // For demonstration, you might do something like:
    // final response = await http.get(Uri.parse('https://example.com/api/shifts'));
    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body) as List;
    //   return data.map((json) => Shift.fromJson(json)).toList();
    // }
    // throw Exception('Failed to load shifts');

    // Mock data
    await Future.delayed(const Duration(seconds: 1));
    return [
      Shift(
        id: '1',
        timeRange: '7:00 AM - 1:00 PM',
        shiftType: 'Morning',
        status: 'Attending',
      ),
      Shift(
        id: '2',
        timeRange: '1:00 PM - 7:00 PM',
        shiftType: 'Day',
        status: 'Pending',
      ),
    ];
  }
}
