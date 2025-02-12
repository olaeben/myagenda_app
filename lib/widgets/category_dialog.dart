import 'package:flutter/material.dart';

import 'custom_text.dart';

class CategoryDialog extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryDialog({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  String? _newCategory;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return AlertDialog(
      title: CustomText(
        'Select Category',
        color: isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.categories.map((category) => ListTile(
                  title: Text(category),
                  selected: category == widget.selectedCategory,
                  onTap: () {
                    widget.onCategorySelected(category);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Add new category',
                border: OutlineInputBorder(),
                errorText: _errorMessage,
                errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _newCategory = value.trim();
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_newCategory == null || _newCategory!.isEmpty) {
                  setState(() {
                    _errorMessage = "Ooops... category name cannot be empty";
                  });
                } else {
                  widget.onCategorySelected(_newCategory);
                  Navigator.pop(context);
                }
              },
              child: const CustomText('Add Category'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCategorySelected(null);
            Navigator.pop(context);
          },
          child: const CustomText2('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const CustomText2('Cancel'),
        ),
      ],
    );
  }
}
