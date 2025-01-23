import 'package:flutter/material.dart';
import 'package:myagenda_app/util/mybutton.dart';

class DialogueBox extends StatefulWidget {
  final TextEditingController controller;
  final DateTime? initialDeadline;

  const DialogueBox({
    super.key,
    required this.controller,
    this.initialDeadline,
  });

  @override
  State<DialogueBox> createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialDeadline != null) {
      selectedDate = widget.initialDeadline;
      selectedTime = TimeOfDay.fromDateTime(widget.initialDeadline!);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate != null && selectedDate!.isAfter(now)
          ? selectedDate!
          : now,
      firstDate: now,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Reset time if date is today and current time is past
        if (picked.year == now.year &&
            picked.month == now.month &&
            picked.day == now.day) {
          final currentTime = TimeOfDay.now();
          if (selectedTime != null &&
              (selectedTime!.hour < currentTime.hour ||
                  (selectedTime!.hour == currentTime.hour &&
                      selectedTime!.minute < currentTime.minute))) {
            selectedTime = null;
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? currentTime,
    );

    if (picked != null && picked != selectedTime) {
      // If selected date is today, validate the time
      if (selectedDate != null &&
          selectedDate!.year == now.year &&
          selectedDate!.month == now.month &&
          selectedDate!.day == now.day) {
        if (picked.hour < currentTime.hour ||
            (picked.hour == currentTime.hour &&
                picked.minute < currentTime.minute)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please select a future time',
                style: TextStyle(
                  color: isLightMode ? Colors.white : Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
              backgroundColor: isLightMode ? Colors.black87 : Colors.white,
            ),
          );
          return;
        }
      }

      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 220,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Add this
              children: [
                TextField(
                  controller: widget.controller,
                  style: TextStyle(
                    color: isLightMode ? Colors.black : Colors.white,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Agenda',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3, // Limit to 3 lines
                  cursorColor: isLightMode ? Colors.black : Colors.white,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: Icon(
                          Icons.calendar_today,
                          color: isLightMode ? Colors.black : Colors.white,
                        ),
                        label: Text(
                          selectedDate == null
                              ? 'Select Date'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _selectTime(context),
                        icon: Icon(
                          Icons.access_time,
                          color: isLightMode ? Colors.black : Colors.white,
                        ),
                        label: Text(
                          selectedTime == null
                              ? 'Select Time'
                              : selectedTime!.format(context),
                          style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyButton(
                      text: 'Save',
                      textColor: isLightMode ? Colors.black : Colors.white,
                      onPressed: () {
                        if (widget.controller.text.trim().isNotEmpty &&
                            selectedDate != null &&
                            selectedTime != null) {
                          final deadline = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );

                          if (deadline.isBefore(DateTime.now())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select a future date and time'),
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).pop({
                            'text': widget.controller.text,
                            'deadline': deadline,
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                            ),
                          );
                        }
                      },
                    ),
                    MyButton(
                      text: 'Cancel',
                      textColor: isLightMode ? Colors.black : Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
