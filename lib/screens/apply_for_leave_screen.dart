import 'package:flutter/material.dart';
import 'package:shift_sl/widgets/leave_widgets.dart';


import '../utils/theme/theme.dart';

class ApplyForLeaveScreen extends StatefulWidget {
  const ApplyForLeaveScreen({Key? key}) : super(key: key);

  @override
  State<ApplyForLeaveScreen> createState() => _ApplyForLeaveScreenState();
}

class _ApplyForLeaveScreenState extends State<ApplyForLeaveScreen> {
  String _selectedType = 'Casual';
  String? _selectedShift;
  final TextEditingController _causeController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _isSingleDayLeave = true; // Default mode: One Day

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
            _endDate = _startDate;
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
      initialChildSize: 0.6, // Half-screen modal
      minChildSize: 0.5,
      maxChildSize: 0.75,
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
              buildDropdown("Type", _selectedType, ["Casual", "Sick", "Special"], (value) {
                setState(() => _selectedType = value!);
              }),

              // Cause Text Field
              buildTextField("Cause", "Enter reason", _causeController),

              // Date Pickers
              buildDatePicker("From", _startDate, () => _selectDate(context, true)),

              if (!_isSingleDayLeave)
                buildDatePicker("To", _endDate, () => _selectDate(context, false)),

              if (_isSingleDayLeave)
                buildDropdown("Shift", _selectedShift, ["Morning", "Day", "Night"], (value) {
                  setState(() => _selectedShift = value!);
                }),

              const Spacer(),

              // Buttons: Cancel & Apply
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Cancel", kDarkColor, Colors.white, () => Navigator.pop(context)),
                  buildButton("Apply for Leave", kSecondaryColor, kPrimaryColor, _applyForLeave),
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
}
