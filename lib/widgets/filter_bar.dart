import 'package:flutter/material.dart';
import 'filter_dialog.dart';
import 'status_filter_dialog.dart';

class FilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final DateTimeRange? selectedDateRange;
  final String? selectedStatus;
  final String? searchFilter;
  final Function(String?) onCategorySelected;
  final Function(DateTimeRange?) onDateRangeSelected;
  final Function(String?) onStatusSelected;
  final VoidCallback onClearFilters;
  final Function(String) onCategoryDeleted;
  final Function(String, String) onCategoryEdited;

  const FilterBar({
    Key? key,
    required this.categories,
    this.selectedCategory,
    this.selectedDateRange,
    this.selectedStatus,
    this.searchFilter,
    required this.onCategorySelected,
    required this.onDateRangeSelected,
    required this.onStatusSelected,
    required this.onClearFilters,
    required this.onCategoryDeleted,
    required this.onCategoryEdited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            if (selectedCategory != null ||
                selectedDateRange != null ||
                searchFilter != null ||
                selectedStatus != null)
              TextButton(
                onPressed: onClearFilters,
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.filter_list,
              size: 20,
              color:
                  isLightMode ? Colors.brown.shade800 : Colors.brown.shade100,
            ),
            const SizedBox(width: 24),
            _buildFilterButton(
              context,
              'Category',
              () => _showCategoryFilter(context),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _showDateFilter(context),
              child: Icon(
                Icons.calendar_today,
                size: 24,
                color: isLightMode ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      height: 36, // Fixed height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          foregroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  Widget _buildFilterButtonWithSelection(
    BuildContext context,
    String label,
    String? selected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected != null ? Theme.of(context).primaryColor : null,
      ),
    );
  }

  Future<void> _showCategoryFilter(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        options: categories,
        selectedOption: selectedCategory,
        onOptionSelected: onCategorySelected,
        onCategoryDeleted: onCategoryDeleted,
        onCategoryEdited: onCategoryEdited,
      ),
    );
  }

  Future<void> _showDateFilter(BuildContext context) async {
    final initialDateRange = selectedDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(Duration(days: 7)),
        );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            colorScheme: ColorScheme(
              brightness: Theme.of(context).brightness,
              primary: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.grey[300]!,
              onPrimary: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
              secondary: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[300]!
                  : Colors.grey[700]!,
              onSecondary: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              error: Colors.red,
              onError: Colors.white,
              background: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[900]!,
              onBackground: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              surface: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[850]!,
              onSurface: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              dayStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
              weekdayStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black87
                    : Colors.white70,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.1),
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedRange != null) {
      onDateRangeSelected(pickedRange);
    }
  }

  Future<void> _showStatusFilter(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => StatusFilterDialog(
        options: const ['completed', 'pending', 'expired'],
        selectedOption: selectedStatus?.toLowerCase(),
        onOptionSelected: (status) {
          if (status != null) {
            onStatusSelected(status.toLowerCase());
          } else {
            onStatusSelected(null);
          }
        },
      ),
    );
  }
}
