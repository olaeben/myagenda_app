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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            if (selectedCategory != null || selectedDateRange != null || searchFilter != null || selectedStatus != null)
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
          mainAxisAlignment: MainAxisAlignment.center,
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
