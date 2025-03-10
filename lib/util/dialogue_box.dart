import 'package:flutter/material.dart';
import '../widgets/custom_text.dart';

class DialogueBox extends StatefulWidget {
  final TextEditingController? controller;
  final DateTime? initialDeadline;
  final String? initialCategory;
  final String? initialDescription;
  final String? initialNotificationFrequency;
  final List<String> categories;
  final Function(String) onCategoryDeleted;
  final bool Function(Map<String, dynamic>)? onSave;
  final bool isEditing;

  const DialogueBox({
    Key? key,
    this.controller,
    this.initialDeadline,
    this.initialCategory,
    this.initialDescription,
    this.initialNotificationFrequency,
    required this.categories,
    required this.onCategoryDeleted,
    this.onSave,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _DialogueBoxState createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  late TextEditingController _controller;
  late DateTime _deadline;
  String? _selectedCategory;
  String _selectedNotificationFrequency = 'Daily';
  bool _isInternalController = false;
  String? _errorMessage;
  String _description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController _descriptionController = TextEditingController();

  final List<String> _notificationFrequencies = [
    'Daily',
    'Weekly',
    'Bi-Weekly',
    'Monthly'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }

    _deadline =
        widget.initialDeadline ?? DateTime.now().add(Duration(hours: 1));
    _selectedCategory = widget.initialCategory ?? 'Default';
    _selectedNotificationFrequency =
        widget.initialNotificationFrequency ?? 'Daily';

    // Initialize description controller with initial description
    _description = widget.initialDescription ?? '';
    _descriptionController = TextEditingController(text: _description);

    // Initialize date and time from deadline
    selectedDate =
        widget.initialDeadline ?? DateTime.now().add(Duration(hours: 1));
    selectedTime = widget.initialDeadline != null
        ? TimeOfDay.fromDateTime(widget.initialDeadline!)
        : TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Material(
      type: MaterialType.transparency,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          Navigator.of(context).pop();
        },
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isLightMode ? Colors.white : Colors.grey[850],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'New Agenda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: isLightMode ? Colors.black45 : Colors.grey,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Title',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Poppins',
                            color:
                                isLightMode ? Colors.black87 : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Fix the TextField controller reference
                        TextField(
                          controller: _controller,
                          style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter title',
                            filled: true,
                            fillColor: isLightMode
                                ? Colors.grey[100]
                                : Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 2),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Additional Description (Optional)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color:
                                isLightMode ? Colors.black87 : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Add description',
                            filled: true,
                            fillColor: isLightMode
                                ? Colors.grey[100]
                                : Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            _description = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryField(),
                        const SizedBox(height: 16),
                        _buildNotificationFrequencyField(),
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
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => _selectTime(context),
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  selectedTime == null
                                      ? 'Select Time'
                                      : selectedTime!.format(context),
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
              if (_errorMessage != null)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomText(
                          _errorMessage!,
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.text.trim().isEmpty) {
                        setState(() {
                          _errorMessage = "Ooops... agenda cannot be empty";
                        });
                        return;
                      }
                      if (!_validateDateTime()) {
                        return;
                      }

                      final result = {
                        'title': _controller.text.trim(),
                        'description': _description,
                        'deadline': DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        ),
                        'category': _selectedCategory ??
                            widget.initialCategory ??
                            'Default',
                        'notificationFrequency': _selectedNotificationFrequency,
                      };

                      // If onSave is provided and returns false, don't pop
                      if (widget.onSave != null) {
                        bool shouldPop = widget.onSave!(result);
                        if (!shouldPop) return;
                      }

                      Navigator.of(context).pop(result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isLightMode ? Colors.black : Colors.white,
                      foregroundColor:
                          isLightMode ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(widget.isEditing ? 'Update' : 'Create',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        )),
                  ),
                ),
              ),
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poppins',
            color: isLightMode ? Colors.black87 : Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isLightMode ? Colors.grey[300]! : Colors.grey[700]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.add,
                    color: isLightMode ? Colors.black54 : Colors.white70,
                  ),
                ),
              ),

              // Category options
              ...widget.categories.map((category) {
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isLightMode ? Colors.black : Colors.black)
                          : (isLightMode ? Colors.grey[100] : Colors.grey[800]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isLightMode ? Colors.black87 : Colors.white70),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Widget _buildNotificationFrequencyField() {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Frequency',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            fontFamily: 'Poppins',
            color: isLightMode ? Colors.black87 : Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLightMode ? Colors.grey[300]! : Colors.grey[700]!,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.notifications,
                  size: 24,
                  color: isLightMode ? Colors.black54 : Colors.white70,
                ),
              ),

              // Frequency options
              ..._notificationFrequencies.map((frequency) {
                final isSelected = frequency == _selectedNotificationFrequency;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedNotificationFrequency = frequency;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isLightMode ? Colors.black : Colors.black)
                          : (isLightMode ? Colors.grey[100] : Colors.grey[800]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      frequency,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isLightMode ? Colors.black87 : Colors.white70),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
