import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_sl/features/core/schedule/schedule_screen_v2.dart';
import 'package:shift_sl/screens/notification_screen.dart';
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import 'package:shift_sl/widgets/leave_shift_card_v2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _upcomingShifts = [];

  @override
  void initState() {
    super.initState();
    _loadCachedDataAndFetchSilently();
  }

  /// Loads cached user and shifts, then silently fetches updated data.
  Future<void> _loadCachedDataAndFetchSilently() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final cachedUser = prefs.getString('doctorData');
    final cachedShifts = prefs.getString('cachedShifts');
    final lastFetchDate = prefs.getString('lastShiftFetchDate');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Load cached user
    if (cachedUser != null) {
      try {
        final userMap = json.decode(cachedUser);
        _user = UserModel.fromJson(userMap);
      } catch (e) {
        print("Error loading cached user: $e");
      }
    }

    // Load cached shifts (if today’s data is available)
    if (cachedShifts != null && lastFetchDate == today) {
      try {
        final List<dynamic> shiftData = json.decode(cachedShifts);
        _processShifts(shiftData);
      } catch (e) {
        print("Error loading cached shifts: $e");
      }
    }

    setState(() => _isLoading = false);

    // Silent background fetch for fresh user data
    fetchUserByFirebaseUid(firebaseUser.uid).then((freshUser) async {
      if (freshUser != null) {
        setState(() => _user = freshUser);
        prefs.setString('doctorData', json.encode(freshUser.toJson()));
      }
    });

    // Fetch shifts from API (this one can use cache unless forced)
    _fetchUserShifts();
  }

  /// Refresh method for pull-to-refresh.
  Future<void> _refreshAll() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final user = await fetchUserByFirebaseUid(firebaseUser.uid);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('doctorData', json.encode(user.toJson()));
        setState(() => _user = user);
      }
    }
    // Force refresh (ignore cached shifts)
    await _fetchUserShifts(forceRefresh: true);
  }

  /// Fetches the user data given a Firebase UID.
  Future<UserModel?> fetchUserByFirebaseUid(String firebaseUid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return null;

    final url = Uri.parse('https://kings.backend.shiftsl.com/api/user/firebase/$firebaseUid');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data);
    }
    print("Failed to fetch user: ${response.statusCode}");
    return null;
  }

  /// Clears the local cached shifts.
  Future<void> _clearShiftCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cachedShifts');
    await prefs.remove('lastShiftFetchDate');
  }

  /// Fetches user shifts from API. If [forceRefresh] is true, it bypasses cache.
  Future<void> _fetchUserShifts({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final doctorId = _user?.id;
    if (token == null || doctorId == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastFetchDate = prefs.getString('lastShiftFetchDate');
    final cachedShifts = prefs.getString('cachedShifts');

    // Use cached data if available and not forced to refresh
    if (!forceRefresh && lastFetchDate == today && cachedShifts != null) {
      final List<dynamic> data = json.decode(cachedShifts);
      _processShifts(data);
      return;
    }

    try {
      final url = Uri.parse('https://kings.backend.shiftsl.com/api/shift/$doctorId');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Save fresh data to cache
        prefs.setString('cachedShifts', json.encode(data));
        prefs.setString('lastShiftFetchDate', today);
        _processShifts(data);
      } else {
        setState(() {
          _errorMessage = 'Failed to load shift data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching shift data: $e';
      });
    }
  }

  /// Processes shift data and extracts upcoming shifts.
  void _processShifts(List<dynamic> data) {
    final now = DateTime.now();
    final upcomingShifts = <Map<String, dynamic>>[];

    for (var shift in data) {
      final shiftStart = DateTime.parse(shift['startTime']).toLocal();
      if (shiftStart.isAfter(now)) {
        upcomingShifts.add({
          "id": shift["id"], // Assuming shift id is provided here.
          "shiftType": _determineShiftType(shift['startTime']),
          "startTime": shift['startTime'],
          "endTime": shift['endTime'],
          "formattedStartTime": _formatTime(shift['startTime']),
          "formattedEndTime": _formatTime(shift['endTime']),
          "shiftDate": shiftStart,
        });
      }
    }

    upcomingShifts.sort((a, b) =>
        (a['shiftDate'] as DateTime).compareTo(b['shiftDate'] as DateTime));

    setState(() {
      _upcomingShifts = upcomingShifts.take(3).toList();
    });
  }

  String _formatTime(String isoTime) {
    try {
      return DateFormat('h:mm a').format(DateTime.parse(isoTime).toLocal());
    } catch (e) {
      return isoTime;
    }
  }

  String _determineShiftType(String startTime) {
    final hour = int.tryParse(startTime.split('T')[1].split(':')[0]) ?? 0;
    if (hour >= 6 && hour < 12) return "Morning Shift";
    if (hour >= 12 && hour < 18) return "Day Shift";
    return "Night Shift";
  }

  String _getDisplayRole(String role) {
    if (role == "DOCTOR_PERM") return "Permanent";
    if (role == "DOCTOR_TEMP") return "Temporary";
    return role;
  }

  Widget _buildErrorWidget() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.red[200]!),
    ),
    child: Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 32),
        const SizedBox(height: 8),
        Text(_errorMessage ?? "An error occurred",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[800])),
        const SizedBox(height: 8),
        TextButton(onPressed: _fetchUserShifts, child: const Text("Retry")),
      ],
    ),
  );

  Widget _buildNoShiftsWidget(String message) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.calendar, color: Colors.grey),
        const SizedBox(width: 8),
        Text(message, style: TextStyle(color: Colors.grey[700])),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Text(
      title,
      style: TextStyle(
        fontSize: ShiftslSizes.fontSizeLg,
        fontWeight: FontWeight.w600,
        color: ShiftslColors.primaryColor,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Image.asset('assets/images/shift_sl_logo.png', height: 100, width: 120),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _user == null
            ? const Center(child: Text("User data not available"))
            : RefreshIndicator(
          onRefresh: _refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        backgroundImage: AssetImage('assets/images/doctor_profile.jpg'),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hello!',
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Dr.${_user!.firstName} ${_user!.lastName}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.white)),
                          Text("King's Hospital",
                              style: TextStyle(
                                  color: ShiftslColors.secondaryColor,
                                  fontSize: ShiftslSizes.fontSizeMd)),
                          Text(_getDisplayRole(_user!.role),
                              style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),
                // Schedule Button
                Container(
                  width: double.infinity,
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ShiftslColors.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Text('New Schedule Published!',
                          style: TextStyle(
                              color: ShiftslColors.white,
                              fontSize: ShiftslSizes.fontSizeMd,
                              fontWeight: FontWeight.w500)),
                      const Spacer(),
                      SizedBox(
                        width: 130,
                        height: 50,
                        child: FilledButton(
                          onPressed: () => Get.to(() => const ShiftManagementScreen()),
                          style: FilledButton.styleFrom(
                            backgroundColor: ShiftslColors.secondaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(10),
                          ),
                          child: const Text('View Schedule',
                              style: TextStyle(
                                  color: ShiftslColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: ShiftslSizes.fontSizeMd)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),
                // Next & Upcoming Shifts
                _sectionTitle("Your Next Shift"),
                const SizedBox(height: 10),
                _errorMessage != null
                    ? _buildErrorWidget()
                    : _upcomingShifts.isEmpty
                    ? _buildNoShiftsWidget("No upcoming shifts found")
                    : LeaveShiftCardV2(
                  shiftType: _upcomingShifts[0]["shiftType"],
                  startTime: _upcomingShifts[0]["startTime"],
                  endTime: _upcomingShifts[0]["endTime"],
                  formattedStartTime: _upcomingShifts[0]["formattedStartTime"],
                  formattedEndTime: _upcomingShifts[0]["formattedEndTime"],
                  selectedDate: _upcomingShifts[0]["shiftDate"],
                  shiftID: _upcomingShifts[0]["id"] ?? 0,
                  doctorID: _user!.id,
                ),
                const SizedBox(height: ShiftslSizes.defaultSpace),
                _sectionTitle("Upcoming Shifts"),
                const SizedBox(height: 10),
                _errorMessage != null
                    ? _buildErrorWidget()
                    : _upcomingShifts.length <= 1
                    ? _buildNoShiftsWidget("No additional upcoming shifts found")
                    : Column(
                  children: List.generate(_upcomingShifts.length - 1, (i) {
                    final shift = _upcomingShifts[i + 1];
                    return Column(
                      children: [
                        LeaveShiftCardV2(
                          shiftType: shift["shiftType"],
                          startTime: shift["startTime"],
                          endTime: shift["endTime"],
                          formattedStartTime: shift["formattedStartTime"],
                          formattedEndTime: shift["formattedEndTime"],
                          selectedDate: shift["shiftDate"],
                          shiftID: shift["id"] ?? 0,
                          doctorID: _user!.id,
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
