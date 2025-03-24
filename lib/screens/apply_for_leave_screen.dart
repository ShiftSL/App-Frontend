import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your own widgets, e.g. buildButton, buildDropdown, buildDatePicker, buildTextField, etc.
// import 'package:shift_sl/widgets/leave_widgets.dart';

// Import your theme colors, e.g. kPrimaryColor, kSecondaryColor, kDarkColor, kLightColor
// import '../utils/theme/theme.dart';

class ApplyForLeaveScreen extends StatefulWidget {
  final int doctorId; // You need the doctorId to fetch shifts
  const ApplyForLeaveScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<ApplyForLeaveScreen> createState() => _ApplyForLeaveScreenState();
}

class _ApplyForLeaveScreenState extends State<ApplyForLeaveScreen> {
  // Leave-related fields
  String _selectedType = 'Casual';
  String? _selectedShift; // For single-day only
  final TextEditingController _causeController = TextEditingController();

  // Date handling
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Toggle between single vs. multiple days
  bool _isSingleDayLeave = true;

  // For loading UI
  bool _isLoading = false;

  // Example shift mapping if you need IDs:
  // Adjust or fetch from server if you have real IDs
  final Map<String, int> _shiftNameToId = {
    "Morning": 1,
    "Day": 2,
    "Night": 3,
  };

  // ------------------------------------------
  // 1. Show date picker
  // ------------------------------------------
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Ensure the "To" date is never before the "From" date
          if (!_isSingleDayLeave && _endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // ------------------------------------------
  // 2. Fetch all shifts for the doctor
  // ------------------------------------------
  Future<List<dynamic>> _fetchShiftsForDoctor(int doctorId) async {
    // Use your real API endpoint here
    final uri = Uri.parse('https://yourapi.com/api/shift/$doctorId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // The response should be a list of shift objects
      // Example: [{ "id": 101, "date": "2025-03-10", "name": "Morning" }, ...]
      return data;
    } else {
      throw Exception('Failed to load shifts from server');
    }
  }

  // ------------------------------------------
  // 3. Post a single leave request
  // ------------------------------------------
  Future<void> _submitLeaveRequest({
    required int shiftId,
    required String type,
    required String cause,
    required int doctorId,
  }) async {
    final uri = Uri.parse('https://yourapi.com/api/leave/request');

    final body = {
      "type": type.toUpperCase(), // e.g. "CASUAL"
      "cause": cause,
      "shiftID": shiftId,
      "doctorID": doctorId,
    };

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit leave request for shift $shiftId');
    }
  }

  // ------------------------------------------
  // 4. Main function to handle "Apply for Leave"
  // ------------------------------------------
  Future<void> _applyForLeave() async {
    // Basic validations
    if (_causeController.text.isEmpty) {
      _showSnackBar("Please enter a cause for the leave.");
      return;
    }

    // If single-day leave, make sure a shift is selected
    if (_isSingleDayLeave && _selectedShift == null) {
      _showSnackBar("Please select a shift.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSingleDayLeave) {
        // -------------------------------------
        // Single-day leave logic
        // -------------------------------------
        // If you have a real shift ID from the server, use that
        // Here, we're mapping shift name to ID as an example:
        final shiftId = _shiftNameToId[_selectedShift!] ?? 0; // fallback 0

        // Submit exactly one leave request
        await _submitLeaveRequest(
          shiftId: shiftId,
          type: _selectedType,
          cause: _causeController.text,
          doctorId: widget.doctorId,
        );

      } else {
        // -------------------------------------
        // Multiple-day leave logic
        // -------------------------------------
        // 1) Fetch all shifts
        final allShifts = await _fetchShiftsForDoctor(widget.doctorId);

        // 2) Filter only those that fall within the chosen date range
        //    Assuming each shift has a 'date' field (YYYY-MM-DD or ISO8601).
        final filteredShifts = allShifts.where((shift) {
          final shiftDate = DateTime.parse(shift['date']);

          // Compare by date (no time)
          final dateOnly = DateTime(shiftDate.year, shiftDate.month, shiftDate.day);
          final startOnly = DateTime(_startDate.year, _startDate.month, _startDate.day);
          final endOnly = DateTime(_endDate.year, _endDate.month, _endDate.day);

          return (dateOnly.isAtSameMomentAs(startOnly) ||
              dateOnly.isAtSameMomentAs(endOnly) ||
              (dateOnly.isAfter(startOnly) && dateOnly.isBefore(endOnly)));
        }).toList();

        if (filteredShifts.isEmpty) {
          _showSnackBar("No shifts found in this date range.");
          return;
        }

        // 3) Submit a leave request for each shift in that range
        for (var shift in filteredShifts) {
          // shift['id'] is presumably the shift's unique ID
          // If the shift object has a different key, adjust accordingly
          await _submitLeaveRequest(
            shiftId: shift['id'],
            type: _selectedType,
            cause: _causeController.text,
            doctorId: widget.doctorId,
          );
        }
      }

      // If we reach here, all requests succeeded
      Navigator.pop(context);
      _showSnackBar("Leave request(s) submitted successfully!", isError: false);
    } catch (e) {
      // Handle any errors from API calls
      _showSnackBar("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper method to show SnackBar
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Draggable bottom sheet or any other UI container
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          // color, decoration, etc. as you like...
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Center(
                child: Text(
                  'New Leave',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // color: kPrimaryColor, // or any color you want
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // TOGGLE: SINGLE VS MULTI-DAY
              _buildToggleButtons(),

              // LEAVE TYPE
              _buildTypeDropdown(),

              // CAUSE TEXT FIELD
              _buildCauseField(),

              // DATE PICKER: FROM
              _buildFromDatePicker(),

              // DATE PICKER: TO (only if multi-day)
              if (!_isSingleDayLeave) _buildToDatePicker(),

              // SHIFT DROPDOWN (only if single-day)
              if (_isSingleDayLeave) _buildShiftDropdown(),

              const Spacer(),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  // Apply
                  ElevatedButton(
                    onPressed: _isLoading ? null : _applyForLeave,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Apply for Leave"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // UI BUILDERS FOR DROPDOWNS, TEXTFIELDS, DATE PICKERS, ETC.
  // ----------------------------------------------------------

  Widget _buildToggleButtons() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleButton("One Day", _isSingleDayLeave),
            _toggleButton("Few Days", !_isSingleDayLeave),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isSingleDayLeave = (label == "One Day")),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      onChanged: (value) => setState(() => _selectedType = value ?? 'Casual'),
      items: ["Casual", "Sick", "Special"].map((type) {
        return DropdownMenuItem(child: Text(type), value: type);
      }).toList(),
      decoration: InputDecoration(labelText: "Leave Type"),
    );
  }

  Widget _buildCauseField() {
    return TextField(
      controller: _causeController,
      decoration: InputDecoration(
        labelText: "Cause",
        hintText: "Enter reason",
      ),
    );
  }

  Widget _buildFromDatePicker() {
    return ListTile(
      title: Text("From (Start Date)"),
      subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
      trailing: Icon(Icons.calendar_today),
      onTap: () => _selectDate(context, true),
    );
  }

  Widget _buildToDatePicker() {
    return ListTile(
      title: Text("To (End Date)"),
      subtitle: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
      trailing: Icon(Icons.calendar_today),
      onTap: () => _selectDate(context, false),
    );
  }

  Widget _buildShiftDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedShift,
      onChanged: (value) => setState(() => _selectedShift = value),
      items: ["Morning", "Day", "Night"].map((shiftName) {
        return DropdownMenuItem(child: Text(shiftName), value: shiftName);
      }).toList(),
      decoration: InputDecoration(labelText: "Shift"),
    );
  }
}
