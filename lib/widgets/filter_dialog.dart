import 'package:flutter/material.dart';

import 'custom_text.dart';

import 'package:rive_animated_icon/rive_animated_icon.dart';

class FilterDialog extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String?) onOptionSelected;
  final Function(String) onCategoryDeleted;

  const FilterDialog({
    Key? key,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
    required this.onCategoryDeleted,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const CustomText('Select Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.options.map((option) => Dismissible(
                  key: Key(option),
                  direction: option == 'Default'
                      ? DismissDirection.none
                      : DismissDirection.endToStart,
                  background: Container(
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
