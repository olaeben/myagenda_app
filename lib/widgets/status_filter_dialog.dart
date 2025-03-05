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

  String _getDisplayText(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  State<StatusFilterDialog> createState() => _StatusFilterDialogState();
}

class _StatusFilterDialogState extends State<StatusFilterDialog> {
  String? _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection =
        widget.selectedOption?.toLowerCase(); // Ensure lowercase
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return AlertDialog(
      title: CustomText(
        'Select Status',
        color: isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.options
              .map((option) => RadioListTile<String>(
                    title: Text(widget._getDisplayText(option)),
                    value: option.toLowerCase(), // Ensure lowercase
                    groupValue: _currentSelection,
                    onChanged: (value) {
                      setState(() {
                        _currentSelection = value;
                      });
                      widget.onOptionSelected(value);
                      Navigator.pop(context);
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
