import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApplyForLeaveSheet extends StatefulWidget {
  const ApplyForLeaveSheet({Key? key}) : super(key: key);

  @override
  State<ApplyForLeaveSheet> createState() => _ApplyForLeaveSheetState();
}

class _ApplyForLeaveSheetState extends State<ApplyForLeaveSheet> {
  // Dropdown values
  String _selectedType = 'Casual';
  String? _selectedShift; // Shift is nullable based on date selection

  // Cause Text Controller
  final TextEditingController _causeController = TextEditingController();

  // Date Variables
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Determines if it's a single-day or multi-day leave
  bool get isSingleDayLeave => _startDate == _endDate;

  // Function to Show Date Picker for Start & End Dates
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
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate; // Adjust end date to match start if it's before
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _applyForLeave() {
    // Handle leave application logic
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave request submitted!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  'New Leave',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),

              // Dropdown: Type
              _buildDropdown("Type", _selectedType, ["Casual", "Sick", "Special"], (value) {
                setState(() => _selectedType = value!);
              }),

              // Text Field: Cause
              _buildTextField("Cause", "Enter reason", _causeController),

              // Date Picker: Start Date
              _buildDatePicker("From", _startDate, () => _selectDate(context, true)),

              // Date Picker: End Date
              _buildDatePicker("To", _endDate, () => _selectDate(context, false)),

              // If it's a **single-day leave**, show Shift selection
              if (isSingleDayLeave)
                _buildDropdown("Shift", _selectedShift, ["Morning", "Day", "Night"], (value) {
                  setState(() => _selectedShift = value!);
                }),

              const Spacer(),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: _applyForLeave,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Apply for leave"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget for Dropdown
  Widget _buildDropdown(String label, String? selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: onChanged,
            items: items.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget for Text Field
  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Date Picker
  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('EEEE, MMM d').format(date)),
                  const Icon(Icons.calendar_today, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
