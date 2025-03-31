import 'package:flutter/material.dart';

class ApplyForLeaveScreen extends StatefulWidget {
  const ApplyForLeaveScreen({Key? key}) : super(key: key);

  @override
  _ApplyForLeaveScreenState createState() => _ApplyForLeaveScreenState();
}

class _ApplyForLeaveScreenState extends State<ApplyForLeaveScreen> {
  bool _isSingleDayLeave = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String? _selectedShift;
  final TextEditingController _causeController = TextEditingController();

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2032),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (!_isSingleDayLeave && _endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyForLeave() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request submitted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      // Provide a scrollController to SingleChildScrollView so that
      // the DraggableScrollableSheet can scroll internally.
      builder: (context, scrollController) {
        return Material(
          // Material is crucial to avoid "No Material widget" errors for
          // things like Dropdown, TextField, etc.
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                // Use min mainAxisSize if you want column to wrap content
                // or keep max if you prefer it to stretch. If it’s large,
                // SingleChildScrollView will handle overflow.
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'New Leave',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle Buttons or Switch for single-day vs. multi-day
                  _buildToggleButtons(),

                  const SizedBox(height: 16),

                  // Cause TextField
                  Text("Cause", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _causeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter reason',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date pickers
                  _buildDatePickerRow(
                    label: "From",
                    date: _startDate,
                    onTap: () => _pickDate(context, true),
                  ),
                  if (!_isSingleDayLeave)
                    _buildDatePickerRow(
                      label: "To",
                      date: _endDate,
                      onTap: () => _pickDate(context, false),
                    ),

                  if (_isSingleDayLeave)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Shift',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                          DropdownMenuItem(value: 'Day', child: Text('Day')),
                          DropdownMenuItem(value: 'Night', child: Text('Night')),
                        ],
                        value: _selectedShift,
                        onChanged: (val) => setState(() => _selectedShift = val),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Button row
                  // If horizontal overflow occurs, you can:
                  // (a) Wrap each button in Flexible/Expanded,
                  // (b) Use a Wrap widget instead of Row,
                  // (c) Or reduce spacing/padding.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // If you suspect overflow, try wrapping in Flexible:
                      Flexible(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: _applyForLeave,
                          child: const Text('Apply for Leave'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // One Day button
        ChoiceChip(
          label: const Text('One Day'),
          selected: _isSingleDayLeave,
          onSelected: (bool selected) => setState(() => _isSingleDayLeave = true),
        ),
        const SizedBox(width: 8),
        // Few Days button
        ChoiceChip(
          label: const Text('Few Days'),
          selected: !_isSingleDayLeave,
          onSelected: (bool selected) => setState(() => _isSingleDayLeave = false),
        ),
      ],
    );
  }

  Widget _buildDatePickerRow({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Text("$label: "),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text("${date.toLocal()}".split(' ')[0]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
