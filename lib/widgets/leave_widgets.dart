import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/theme/theme.dart';


/// Custom Elevated Button
Widget buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
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

/// Custom Dropdown Selector
Widget buildDropdown(String label, String? selectedValue, List<String> items, ValueChanged<String?> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

/// Custom Text Field
Widget buildTextField(String label, String hint, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

/// Custom Date Picker
Widget buildDatePicker(String label, DateTime date, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
