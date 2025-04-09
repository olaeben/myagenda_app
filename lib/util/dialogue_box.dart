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
  final Function()? onAddCategory;

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
    this.onAddCategory,
  }) : super(key: key);

  @override
  _DialogueBoxState createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  late TextEditingController _controller;
  late DateTime _deadline;
  String? _selectedCategory;
  late String _selectedNotificationFrequency;
  bool _isInternalController = false;
  String? _errorMessage;
  String _description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController _descriptionController = TextEditingController();
  String? _notificationFrequencyError;

  final List<String> _notificationFrequencies = ['Daily', 'Custom'];
  final List<bool> _selectedDays = List.filled(7, false);
  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  bool _showDayPicker = false;

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
    if (!_notificationFrequencies.contains(_selectedNotificationFrequency)) {
      if (widget.initialNotificationFrequency != null &&
          widget.initialNotificationFrequency!.startsWith('Custom:')) {
        _selectedNotificationFrequency = 'Custom';
        String daysString = widget.initialNotificationFrequency!.substring(7);
        List<String> selectedDayNames = daysString.split(',');

        for (int i = 0; i < _selectedDays.length; i++) {
          _selectedDays[i] = false;
        }

        for (String dayName in selectedDayNames) {
          int index = _daysOfWeek.indexOf(dayName);
          if (index != -1) {
            _selectedDays[index] = true;
          }
        }
      } else {
        _selectedNotificationFrequency = 'Daily';
      }
    }

    _description = widget.initialDescription ?? '';
    _descriptionController = TextEditingController(text: _description);
    selectedDate =
        widget.initialDeadline ?? DateTime.now().add(Duration(hours: 1));
    selectedTime = widget.initialDeadline != null
        ? TimeOfDay.fromDateTime(widget.initialDeadline!)
        : TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));

    _controller.addListener(() {
      setState(() {});
    });
    _descriptionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(DialogueBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNotificationFrequency !=
        oldWidget.initialNotificationFrequency) {
      setState(() {
        _selectedNotificationFrequency =
            widget.initialNotificationFrequency ?? 'Daily';
        if (!_notificationFrequencies
            .contains(_selectedNotificationFrequency)) {
          _selectedNotificationFrequency = 'Daily';
        }
      });
    }
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Material(
        type: MaterialType.transparency,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            Navigator.of(context).pop();
          },
          child: SafeArea(
            bottom: false,
            maintainBottomViewPadding: true,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: statusBarHeight > 0 ? statusBarHeight + 8 : 8,
              ),
              decoration: BoxDecoration(
                color: isLightMode ? Colors.white : Colors.grey[850],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Scrollbar(
                thickness: 3.0,
                radius: Radius.circular(3.0),
                thumbVisibility: true,
                interactive: true,
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 8.0,
                      bottom: 16.0,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Add New Agenda',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color:
                                    isLightMode ? Colors.black45 : Colors.grey,
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
                                      color: isLightMode
                                          ? Colors.black87
                                          : Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _controller,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    style: TextStyle(
                                      color: isLightMode
                                          ? Colors.black
                                          : Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter title',
                                      hintStyle: TextStyle(
                                        color: isLightMode
                                            ? Colors.black26
                                            : Colors.grey[300],
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: isLightMode
                                          ? Colors.grey[100]
                                          : Colors.grey[800],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 2),
                                      counterText:
                                          '${_controller.text.length}/35',
                                      counterStyle: TextStyle(
                                        color: _controller.text.length > 35
                                            ? Colors.red
                                            : (isLightMode
                                                ? Colors.black54
                                                : Colors.grey[400]),
                                        fontSize: 12,
                                      ),
                                    ),
                                    maxLines: 1,
                                    maxLength: 35,
                                    buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) {
                                      return Container();
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Additional Description (Optional)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: isLightMode
                                          ? Colors.black87
                                          : Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _descriptionController,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    onSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Enter description',
                                      hintStyle: TextStyle(
                                        color: isLightMode
                                            ? Colors.black26
                                            : Colors.grey[300],
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: isLightMode
                                          ? Colors.grey[100]
                                          : Colors.grey[800],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      counterText:
                                          '${_descriptionController.text.length}/574',
                                      counterStyle: TextStyle(
                                        color:
                                            _descriptionController.text.length >
                                                    574
                                                ? Colors.red
                                                : (isLightMode
                                                    ? Colors.black54
                                                    : Colors.grey[400]),
                                        fontSize: 12,
                                      ),
                                    ),
                                    maxLines: 3,
                                    maxLength: 574,
                                    buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) {
                                      return Container();
                                    },
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
                                            color: isLightMode
                                                ? Colors.black
                                                : Colors.white,
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
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
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
                                    _errorMessage =
                                        "Ooops... agenda title is required";
                                  });
                                  return;
                                }
                                if (_controller.text.length > 35) {
                                  setState(() {
                                    _errorMessage =
                                        "Title cannot exceed 35 characters";
                                  });
                                  return;
                                }
                                if (_descriptionController.text.length > 574) {
                                  setState(() {
                                    _errorMessage =
                                        "Description cannot exceed 574 characters";
                                  });
                                  return;
                                }
                                if (!_validateDateTime()) {
                                  return;
                                }

                                String notificationFrequency =
                                    _selectedNotificationFrequency;
                                if (_selectedNotificationFrequency ==
                                        'Custom' &&
                                    _selectedDays.contains(true)) {
                                  List<String> selectedDayNames = [];
                                  for (int i = 0;
                                      i < _selectedDays.length;
                                      i++) {
                                    if (_selectedDays[i]) {
                                      selectedDayNames.add(_daysOfWeek[i]);
                                    }
                                  }
                                  notificationFrequency =
                                      'Custom:${selectedDayNames.join(',')}';
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
                                  'notificationFrequency':
                                      notificationFrequency,
                                };

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
                              child:
                                  Text(widget.isEditing ? 'Update' : 'Create',
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateDateTime() {
    final now = DateTime.now();
    if (selectedDate == null || selectedTime == null) {
      setState(() {
        _errorMessage =
            selectedDate == null ? 'Date is required' : 'Please select time';
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
    _validateNotificationFrequency();
    if (_notificationFrequencyError != null) {
      setState(() {
        _errorMessage = _notificationFrequencyError;
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
      fieldLabelText: 'Enter Date',
      errorFormatText: 'Date is required',
      errorInvalidText: 'Date is required',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              errorStyle: TextStyle(color: Colors.red),
            ),
          ),
          child: child!,
        );
      },
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
        _validateNotificationFrequency();
      });
    } else if (picked == null && selectedDate != null) {
      setState(() {
        _errorMessage = "Date is required";
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
        _validateNotificationFrequency();
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
              GestureDetector(
                onTap: () async {
                  if (widget.onAddCategory != null) {
                    await widget.onAddCategory!();
                    setState(() {});
                  }
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
                      if (frequency == 'Custom') {
                        _showDayPicker = true;
                        _showDayPickerModal(context);
                      }
                      _validateNotificationFrequency();
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
        if (_selectedNotificationFrequency == 'Custom' &&
            _selectedDays.contains(true))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: List.generate(
                _selectedDays.length,
                (index) => _selectedDays[index]
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              isLightMode ? Colors.grey[200] : Colors.grey[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _daysOfWeek[index],
                          style: TextStyle(
                            color:
                                isLightMode ? Colors.black87 : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Container(),
              ),
            ),
          ),
      ],
    );
  }

  void _showDayPickerModal(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Days for Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(
                  7,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDays[index] = !_selectedDays[index];
                      });
                      this.setState(() {});
                      _validateNotificationFrequency();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedDays[index]
                            ? (isLightMode ? Colors.black : Colors.white)
                            : (isLightMode
                                ? Colors.grey[200]
                                : Colors.grey[700]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _daysOfWeek[index],
                        style: TextStyle(
                          color: _selectedDays[index]
                              ? (isLightMode ? Colors.white : Colors.black)
                              : (isLightMode ? Colors.black87 : Colors.white70),
                          fontWeight: _selectedDays[index]
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLightMode ? Colors.black : Colors.white,
                  foregroundColor: isLightMode ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateNotificationFrequency() {
    setState(() {
      _notificationFrequencyError = null;
    });

    if (selectedDate == null || selectedTime == null) {
      return;
    }

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      setState(() {
        _notificationFrequencyError = "Please select a future date and time.";
      });
      return;
    }

    if (_selectedNotificationFrequency == 'Custom' &&
        !_selectedDays.contains(true)) {
      setState(() {
        _notificationFrequencyError =
            "Please select at least one day for notifications.";
      });
    }
  }
}
