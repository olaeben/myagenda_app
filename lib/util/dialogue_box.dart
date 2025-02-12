import 'package:flutter/material.dart';
import 'package:myagenda_app/util/mybutton.dart';
import '../widgets/custom_text.dart';

class DialogueBox extends StatefulWidget {
  final TextEditingController controller;
  final DateTime? initialDeadline;
  final String? initialCategory;
  final List<String> categories;
  final Function(String) onCategoryDeleted;

  const DialogueBox({
    Key? key,
    required this.controller,
    this.initialDeadline,
    this.initialCategory,
    required this.categories,
    required this.onCategoryDeleted,
  }) : super(key: key);

  @override
  _DialogueBoxState createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? _selectedCategory;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      maxLines: 3,
                      cursorColor: isLightMode ? Colors.black : Colors.white,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: Icon(
                              Icons.calendar_today,
                              color: isLightMode
                                  ? Colors.brown.shade800
                                  : Colors.brown.shade100,
                            ),
                            label: Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isLightMode
                                      ? Colors.brown.shade800
                                      : Colors.brown.shade100,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: Icon(
                              Icons.access_time,
                              color: isLightMode
                                  ? Colors.brown.shade800
                                  : Colors.brown.shade100,
                            ),
                            label: Text(
                              selectedTime == null
                                  ? 'Select Time'
                                  : selectedTime!.format(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isLightMode
                                    ? Colors.brown.shade800
                                    : Colors.brown.shade100,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomText(
                  _errorMessage!,
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    text: 'Save',
                    textColor: isLightMode
                        ? Colors.brown.shade800
                        : Colors.brown.shade700,
                    onPressed: () {
                      setState(() {
                        if (widget.controller.text.trim().isEmpty) {
                          _errorMessage = "Ooops... agenda cannot be empty";
                          return;
                        }
                        if (selectedDate == null || selectedTime == null) {
                          _errorMessage = "Please select both date and time";
                          return;
                        }

                        final deadline = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );

                        if (deadline.isBefore(DateTime.now())) {
                          _errorMessage =
                              "Please select a future date and time";
                          return;
                        }

                        _errorMessage = null;
                        Navigator.of(context).pop({
                          'text': widget.controller.text,
                          'category': _selectedCategory ?? 'Default',
                          'deadline': deadline,
                        });
                      });
                    },
                  ),
                  MyButton(
                    text: 'Cancel',
                    textColor: isLightMode
                        ? Colors.brown.shade800
                        : Colors.brown.shade700,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateDateTime() {
    final now = DateTime.now();
    if (selectedDate == null || selectedTime == null) {
      setState(() {
        _errorMessage = 'Please select both date and time';
      });
      return false;
    }

    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      setState(() {
        _errorMessage = 'Please select a future date and time';
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  Future<void> _selectDate(BuildContext context) async {
    setState(() => _errorMessage = null);
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
    setState(() => _errorMessage = null);
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? currentTime,
    );

    if (picked != null && picked != selectedTime) {
      if (selectedDate != null &&
          selectedDate!.year == now.year &&
          selectedDate!.month == now.month &&
          selectedDate!.day == now.day) {
        if (picked.hour < currentTime.hour ||
            (picked.hour == currentTime.hour &&
                picked.minute < currentTime.minute)) {
          _showErrorMessage(context, 'Please select a future time');
          return;
        }
      }

      setState(() {
        selectedTime = picked;
      });
    }
  }

  Widget _buildCategoryField() {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return DropdownButtonFormField<String>(
      value: _selectedCategory ?? widget.initialCategory ?? 'Default',
      items: widget.categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(
            category,
            style: TextStyle(
              color: isLightMode ? Colors.black : Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: TextStyle(
          color: isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
        ),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    setState(() {
      _errorMessage = message;
    });
  }
}
