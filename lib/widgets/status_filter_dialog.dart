import 'package:flutter/material.dart';
import 'custom_text.dart';

class StatusFilterDialog extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String?) onOptionSelected;

  const StatusFilterDialog({
    Key? key,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  State<StatusFilterDialog> createState() => _StatusFilterDialogState();
}

class _StatusFilterDialogState extends State<StatusFilterDialog> {
  String? _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const CustomText('Select Status'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.options
              .map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _currentSelection,
                    onChanged: (value) {
                      setState(() {
                        _currentSelection = value;
                      });
                      widget.onOptionSelected(value);
                    },
                  ))
              .toList(),
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
