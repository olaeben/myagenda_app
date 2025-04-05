import 'package:flutter/material.dart';

import 'custom_text.dart';

import 'package:rive_animated_icon/rive_animated_icon.dart';

class FilterDialog extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String?) onOptionSelected;
  final Function(String) onCategoryDeleted;
  final Function(String, String) onCategoryEdited;

  const FilterDialog({
    Key? key,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
    required this.onCategoryDeleted,
    required this.onCategoryEdited,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _currentSelection;
  bool _showSuccess = false;
  String? _editedCategory;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedOption;
  }

  void _showEditCategoryDialog(BuildContext context, String category) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final TextEditingController _editCategoryController =
        TextEditingController(text: category);
    bool _showEditSuccess = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isLightMode ? Colors.white : Colors.grey[850],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar at top
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
                  _showEditSuccess
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: RiveAnimatedIcon(
                                riveIcon: RiveIcon.check,
                                width: 60,
                                height: 60,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Category Updated',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isLightMode ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Category',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color:
                                    isLightMode ? Colors.black45 : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _editCategoryController,
                              maxLength: 14,
                              decoration: InputDecoration(
                                hintText: 'Enter category name',
                                hintStyle: TextStyle(
                                  color: isLightMode
                                      ? Colors.black26
                                      : Colors.grey[100],
                                ),
                                filled: true,
                                fillColor: isLightMode
                                    ? Colors.grey[100]
                                    : Colors.grey[800],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              autofocus: true,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_editCategoryController
                                        .text.isNotEmpty) {
                                      final newCategoryName =
                                          _editCategoryController.text;
                                      if (newCategoryName != category) {
                                        widget.onCategoryEdited(
                                            category, newCategoryName);
                                        setModalState(() {
                                          _showEditSuccess = true;
                                        });

                                        setState(() {
                                          _showSuccess = true;
                                          _editedCategory = newCategoryName;

                                          if (_currentSelection == category) {
                                            _currentSelection = newCategoryName;
                                          }

                                          final index =
                                              widget.options.indexOf(category);
                                          if (index != -1) {
                                            widget.options[index] =
                                                newCategoryName;
                                          }
                                        });

                                        Future.delayed(Duration(seconds: 1),
                                            () {
                                          Navigator.pop(context);
                                        });
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    backgroundColor: isLightMode
                                        ? Colors.black
                                        : Colors.white,
                                    foregroundColor: isLightMode
                                        ? Colors.white
                                        : Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text('Save'),
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final TextEditingController _addCategoryController =
        TextEditingController();
    bool _showAddSuccess = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isLightMode ? Colors.white : Colors.grey[850],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar at top
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
                  _showAddSuccess
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: RiveAnimatedIcon(
                                riveIcon: RiveIcon.check,
                                width: 60,
                                height: 60,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Category Added',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isLightMode ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Category',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color:
                                    isLightMode ? Colors.black45 : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _addCategoryController,
                              maxLength: 14,
                              decoration: InputDecoration(
                                hintText: 'Enter category name',
                                hintStyle: TextStyle(
                                  color: isLightMode
                                      ? Colors.black26
                                      : Colors.grey[100],
                                ),
                                filled: true,
                                fillColor: isLightMode
                                    ? Colors.grey[100]
                                    : Colors.grey[800],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              autofocus: true,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_addCategoryController
                                        .text.isNotEmpty) {
                                      final newCategoryName =
                                          _addCategoryController.text;
                                      widget.onCategoryEdited(
                                          '', newCategoryName);

                                      setModalState(() {
                                        _showAddSuccess = true;
                                      });

                                      setState(() {
                                        _showSuccess = true;
                                        _editedCategory = newCategoryName;

                                        widget.options.add(newCategoryName);
                                      });

                                      // Close modal after delay
                                      Future.delayed(Duration(seconds: 1), () {
                                        Navigator.pop(context);
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    backgroundColor: isLightMode
                                        ? Colors.black
                                        : Colors.white,
                                    foregroundColor: isLightMode
                                        ? Colors.white
                                        : Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text('Save'),
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    if (_showSuccess) {
      Future.delayed(Duration.zero, () {
        setState(() {
          _showSuccess = false;
        });
      });
    }

    return AlertDialog(
      title: CustomText(
        'Select Category',
        color: isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.options.map((option) => Dismissible(
                  key: Key(option),
                  direction: option == 'Default'
                      ? DismissDirection.none
                      : DismissDirection.horizontal,
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: RiveAnimatedIcon(
                      riveIcon: RiveIcon.edit,
                      width: 30,
                      height: 30,
                      color: Colors.white,
                      strokeWidth: 3,
                      loopAnimation: true,
                      onTap: () {},
                      onHover: (value) {},
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: RiveAnimatedIcon(
                      riveIcon: RiveIcon.bin,
                      width: 30,
                      height: 30,
                      color: Colors.white,
                      strokeWidth: 3,
                      loopAnimation: true,
                      onTap: () {},
                      onHover: (value) {},
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (option == 'Default') return false;

                    if (direction == DismissDirection.startToEnd) {
                      _showEditCategoryDialog(context, option);
                      return false;
                    } else {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: CustomText('Delete Category?'),
                          content: CustomText2(
                              'Are you sure you want to delete "$option"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: CustomText2('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: CustomText2('Delete'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  onDismissed: (_) => widget.onCategoryDeleted(option),
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _currentSelection,
                    onChanged: (value) {
                      setState(() {
                        _currentSelection = value;
                      });
                      widget.onOptionSelected(value);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const CustomText2('Close'),
        ),
      ],
    );
  }
}
