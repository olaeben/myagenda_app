import 'package:flutter/material.dart';

import 'custom_text.dart';

class CategorySelector extends StatefulWidget {
  final List<String> categories;
  final String? initialCategory;
  final Function(String) onCategorySelected;
  final Function(String) onNewCategoryAdded;
  final Function(String) onCategoryDeleted;

  const CategorySelector({
    Key? key,
    required this.categories,
    this.initialCategory,
    required this.onCategorySelected,
    required this.onNewCategoryAdded,
    required this.onCategoryDeleted,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late TextEditingController _newCategoryController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _newCategoryController = TextEditingController();
    _selectedCategory = widget.initialCategory ?? 'Default';
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          'Add New Category',
          color: isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
        ),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText2(
              'Cancel',
              color:
                  isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
            ),
          ),
          TextButton(
            onPressed: () {
              if (_newCategoryController.text.isNotEmpty) {
                final newCategory = _newCategoryController.text;
                void _addNewCategory(String newCategory) {
                  if (widget.onNewCategoryAdded != null) {
                    widget.onNewCategoryAdded(newCategory);
                  }
                  widget.onCategorySelected(newCategory);
                }

                setState(() {
                  _selectedCategory = newCategory;
                });
                widget.onCategorySelected(newCategory);
                _newCategoryController.clear();
                Navigator.pop(context);
              }
            },
            child: CustomText2(
              'Add',
              color:
                  isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.categories.map(
          (category) => category != 'Default'
              ? Dismissible(
                  key: Key(category),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: CustomText(
                          'Delete Category?',
                          color: isLightMode
                              ? Colors.brown.shade800
                              : Colors.brown.shade100,
                        ),
                        content: CustomText2(
                          'Are you sure you want to delete "$category"?',
                          color: isLightMode
                              ? Colors.brown.shade800
                              : Colors.brown.shade100,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: CustomText2(
                              'Cancel',
                              color: isLightMode
                                  ? Colors.brown.shade800
                                  : Colors.brown.shade100,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: CustomText2(
                              'Delete',
                              color: isLightMode
                                  ? Colors.brown.shade800
                                  : Colors.brown.shade100,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    widget.onCategoryDeleted(category);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: RadioListTile<String>(
                    title: Text(category),
                    value: category,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      if (value != null) {
                        widget.onCategorySelected(value);
                      }
                    },
                  ),
                )
              : RadioListTile<String>(
                  // Default category without delete option
                  title: Text(category),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    if (value != null) {
                      widget.onCategorySelected(value);
                    }
                  },
                ),
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: CustomText(
            'Add New Category',
            color: isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
          ),
          onTap: _showAddCategoryDialog,
        ),
      ],
    );
  }
}
