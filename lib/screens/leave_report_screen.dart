import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shift_sl/utils/constants/colors.dart';
import 'package:shift_sl/utils/constants/sizes.dart';
import '../models/user.dart';

class LeaveReportScreen extends StatefulWidget {
  const LeaveReportScreen({Key? key}) : super(key: key);

  @override
  State<LeaveReportScreen> createState() => _LeaveReportScreenState();
}

class _LeaveReportScreenState extends State<LeaveReportScreen> {
  Map<String, dynamic> _leaveReport = {};
  bool _isLoading = true;
  String? _errorMessage;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserAndReport();
  }

  Future<void> _loadUserAndReport() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUserData = prefs.getString('doctorData');
    if (cachedUserData != null) {
      try {
        final decoded = json.decode(cachedUserData);
        _user = UserModel.fromJson(decoded);
      } catch (e) {
        print("Error decoding user data: $e");
      }
    }
    if (_user == null) {
      setState(() {
        _errorMessage = "User data unavailable.";
        _isLoading = false;
      });
      return;
    }
    _fetchLeaveReport();
  }

  Future<void> _fetchLeaveReport() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      setState(() {
        _errorMessage = "No auth token found.";
        _isLoading = false;
      });
      return;
    }
    try {
      // Adjust the endpoint as needed.
      final url =
      Uri.parse("https://kings.backend.shiftsl.com/api/leave/byDoc/${_user!.id}");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          // Aggregate the list into a report.
          int total = data.length;
          int approved = 0;
          int pending = 0;
          int rejected = 0;
          for (var leave in data) {
            final status = (leave["status"] ?? "").toString().toUpperCase();
            if (status == "APPROVED") {
              approved++;
            } else if (status == "PENDING") {
              pending++;
            } else if (status == "REJECTED") {
              rejected++;
            }
          }
          setState(() {
            _leaveReport = {
              "totalLeaves": total,
              "approvedLeaves": approved,
              "pendingLeaves": pending,
              "rejectedLeaves": rejected,
            };
            _isLoading = false;
          });
        } else if (data is Map<String, dynamic>) {
          // If a map is returned instead (already aggregated), use it.
          setState(() {
            _leaveReport = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Unexpected data format.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to load leave report: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching leave report: $e";
        _isLoading = false;
      });
    }
  }

  /// Builds a pie chart using fl_chart to visualize the leave report data.
  Widget _buildPieChart() {
    // Extract approved, pending, and rejected values.
    final approved = _leaveReport['approvedLeaves'] ?? 0;
    final pending = _leaveReport['pendingLeaves'] ?? 0;
    final rejected = _leaveReport['rejectedLeaves'] ?? 0;
    final total = approved + pending + rejected;

    if (total == 0) {
      return const Text("No leave data available to display a chart.",
          style: TextStyle(fontSize: ShiftslSizes.fontSizeMd));
    }

    final approvedPerc = approved / total * 100;
    final pendingPerc = pending / total * 100;
    final rejectedPerc = rejected / total * 100;

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: approved.toDouble(),
              title: "${approvedPerc.toStringAsFixed(0)}%",
              radius: 60,
              titleStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: pending.toDouble(),
              title: "${pendingPerc.toStringAsFixed(0)}%",
              radius: 60,
              titleStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.red,
              value: rejected.toDouble(),
              title: "${rejectedPerc.toStringAsFixed(0)}%",
              radius: 60,
              titleStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLeaveReportText(Map<String, dynamic> report) {
    return "Total Leaves: ${report['totalLeaves'] ?? 0}\n"
        "Approved: ${report['approvedLeaves'] ?? 0}\n"
        "Pending: ${report['pendingLeaves'] ?? 0}\n"
        "Rejected: ${report['rejectedLeaves'] ?? 0}";
  }

  /// Builds a small legend item with color and label.
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Report',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _formatLeaveReportText(_leaveReport),
                  style: const TextStyle(
                      fontSize: ShiftslSizes.fontSizeMd),
                ),
                const SizedBox(height: 20),
                _buildPieChart(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem("Approved", Colors.green),
                    _buildLegendItem("Pending", Colors.orange),
                    _buildLegendItem("Rejected", Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
