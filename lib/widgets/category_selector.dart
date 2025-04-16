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

  void _showAddCategoryDialog() {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddCategoryContent(isLightMode),
    );
  }

  Widget _buildAddCategoryContent(bool isLightMode) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isLightMode ? Colors.white : Colors.grey[850],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  Navigator.of(context).pop();
                }
              },
              child: Center(
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
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add New Category',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: isLightMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _newCategoryController,
                    decoration: InputDecoration(
                      hintText: 'Enter category name',
                      hintStyle: TextStyle(
                        color: isLightMode ? Colors.black26 : Colors.grey[100],
                      ),
                      filled: true,
                      fillColor: isLightMode ? Colors.grey[100] : Colors.grey[800],
                      border: UnderlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_newCategoryController.text.isNotEmpty) {
                          final newCategory = _newCategoryController.text;
                          setState(() {
                            _selectedCategory = newCategory;
                          });
                          widget.onNewCategoryAdded(newCategory);
                          widget.onCategorySelected(newCategory);
                          _newCategoryController.clear();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLightMode ? Colors.black : Colors.white,
                        foregroundColor: isLightMode ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Create',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
