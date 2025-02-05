import 'package:flutter/material.dart';

import '../widgets/custom_text.dart';

class MultiSelectBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const MultiSelectBar({
    super.key,
    required this.selectedCount,
    required this.onComplete,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancel,
          ),
          CustomText('$selectedCount selected'),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: onComplete,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
