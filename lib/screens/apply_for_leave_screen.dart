import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// SHIFT SL brand colors
const Color kPrimaryColor = Color(0xFF131313);
const Color kSecondaryColor = Color(0xFF2AED8D);
const Color kDarkColor = Color(0xFF242424);
const Color kLightColor = Color(0xFFF7F7F7);

class ApplyForLeaveSheet extends StatefulWidget {
  const ApplyForLeaveSheet({Key? key}) : super(key: key);

  @override
  State<ApplyForLeaveSheet> createState() => _ApplyForLeaveSheetState();
}

class _ApplyForLeaveSheetState extends State<ApplyForLeaveSheet> {
  String _selectedType = 'Casual';
  String? _selectedShift;
  final TextEditingController _causeController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _isSingleDayLeave = true; // Default mode: One Day Leave

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
          if (!_isSingleDayLeave && _endDate.isBefore(_startDate)) {
            _endDate = _startDate; // Ensure correct order
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _applyForLeave() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Leave request submitted!", style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.75,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kLightColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Text(
                  'New Leave',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Toggle Button: One Day / Few Days
              _buildToggleButtons(),

              // Leave Type Dropdown
              _buildDropdown("Type", _selectedType, ["Casual", "Sick", "Special"], (value) {
                setState(() => _selectedType = value!);
              }),

              // Cause Text Field
              _buildTextField("Cause", "Enter reason", _causeController),

              // Date Picker: Start Date
              _buildDatePicker("From", _startDate, () => _selectDate(context, true)),

              // Date Picker: End Date (Only if in "Few Days" mode)
              if (!_isSingleDayLeave)
                _buildDatePicker("To", _endDate, () => _selectDate(context, false)),

              // Shift selection (Only if "One Day" mode)
              if (_isSingleDayLeave)
                _buildDropdown("Shift", _selectedShift, ["Morning", "Day", "Night"], (value) {
                  setState(() => _selectedShift = value!);
                }),

              const Spacer(),

              // Buttons: Cancel & Apply
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton("Cancel", kDarkColor, Colors.white, () => Navigator.pop(context)),
                  _buildButton("Apply for Leave", kSecondaryColor, kPrimaryColor, _applyForLeave),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Toggle Button UI
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

  // Toggle Button Item
  Widget _toggleButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isSingleDayLeave = label == "One Day"),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? kSecondaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? kPrimaryColor : kDarkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Dropdown UI
  Widget _buildDropdown(String label, String? selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onChanged: onChanged,
              items: items.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: kPrimaryColor)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Text Field UI
  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  // Date Picker UI
  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('EEEE, MMM d').format(date)),
                  const Icon(Icons.calendar_today, color: kDarkColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
