import 'package:flutter/material.dart';

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
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  final int _maxCategoryLength = 14;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: isLightMode ? Colors.white : Colors.grey[850],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Category',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black45 : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter category name',
                      hintStyle: TextStyle(
                        color: isLightMode ? Colors.black26 : Colors.grey[100],
                      ),
                      filled: true,
                      fillColor:
                          isLightMode ? Colors.grey[100] : Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      counterText:
                          '${_controller.text.length}/$_maxCategoryLength',
                      counterStyle: TextStyle(
                        color: _controller.text.length > _maxCategoryLength
                            ? Colors.red
                            : (isLightMode ? Colors.black54 : Colors.grey[400]),
                        fontSize: 12,
                      ),
                    ),
                    maxLength: _maxCategoryLength,
                    buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) {
                      return Container();
                    },
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final category = _controller.text.trim();
                      if (category.isEmpty) {
                        setState(() {
                          _errorMessage = 'Category name cannot be empty';
                        });
                        return;
                      }
                      if (category.length > _maxCategoryLength) {
                        setState(() {
                          _errorMessage =
                              'Category name cannot exceed $_maxCategoryLength characters';
                        });
                        return;
                      }
                      if (widget.categories.any((existingCategory) =>
                          existingCategory.toLowerCase() ==
                          category.toLowerCase())) {
                        setState(() {
                          _errorMessage = 'Ooops... category already exists';
                        });
                        return;
                      }
                      Navigator.pop(context, category);
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor:
                          isLightMode ? Colors.black : Colors.white,
                      foregroundColor:
                          isLightMode ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Create'),
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
