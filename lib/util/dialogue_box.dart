import 'package:flutter/material.dart';
import 'package:myagenda_app/util/mybutton.dart';

import '../widgets/category_selector.dart';
import '../widgets/custom_text.dart';

class DialogueBox extends StatefulWidget {
  final TextEditingController controller;
  final DateTime? initialDeadline;
  final String? initialCategory;
  final List<String> categories;
  final Function(String) onNewCategoryAdded;
  final Function(String) onCategoryDeleted;

  const DialogueBox({
    Key? key,
    required this.controller,
    this.initialDeadline,
    this.initialCategory,
    required this.categories,
    required this.onNewCategoryAdded,
    required this.onCategoryDeleted,
  }) : super(key: key);

  @override
  _DialogueBoxState createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (widget.initialDeadline != null) {
      selectedDate = widget.initialDeadline;
      selectedTime = TimeOfDay.fromDateTime(widget.initialDeadline!);
    }
  }

  Widget _buildCategoryField() {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const CustomText('Select Category'),
              content: CategorySelector(
                categories: widget.categories,
                initialCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
                onNewCategoryAdded: (newCategory) {
                  setState(() {
                    _selectedCategory = newCategory;
                  });
                },
                onCategoryDeleted: widget.onCategoryDeleted,
              ),
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          _selectedCategory ?? 'Select Category',
          style: TextStyle(
            color: isLightMode ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.amber,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
            Flexible(
              child: SingleChildScrollView(
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
                                color:
                                    isLightMode ? Colors.black : Colors.white,
                              ),
                              label: Text(
                                selectedDate == null
                                    ? 'Select Date'
                                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white,
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
                                color:
                                    isLightMode ? Colors.black : Colors.white,
                              ),
                              label: Text(
                                selectedTime == null
                                    ? 'Select Time'
                                    : selectedTime!.format(context),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      isLightMode ? Colors.black : Colors.white,
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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
                              content: CustomText(
                                  'Please select a future date and time'),
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pop({
                          'text': widget.controller.text,
                          'category': _selectedCategory ?? 'Default',
                          'deadline': deadline,
                        });
                      } else {
                        void _showErrorMessage(
                            BuildContext context, String message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: Colors.amber,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              elevation: 8,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  MyButton(
                    text: 'Cancel',
                    textColor: isLightMode ? Colors.black : Colors.white,
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
}
