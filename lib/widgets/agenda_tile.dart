import 'package:flutter/material.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import '../models/agenda_model.dart';
import 'custom_text.dart';

class AgendaTile extends StatelessWidget {
  final AgendaModel agenda;
  final Function(bool?) onStatusChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final bool showCheckbox;

  const AgendaTile({
    Key? key,
    required this.agenda,
    required this.onStatusChanged,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.showCheckbox = false,
  }) : super(key: key);

  Widget _buildStatusIndicator(BuildContext context) {
    final now = DateTime.now();
    final isExpired = now.isAfter(agenda.deadline);

    Color color;
    if (agenda.status) {
      color = Colors.green;
    } else if (isExpired) {
      color = Colors.red;
    } else {
      color = Colors.amber;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = now.isAfter(agenda.deadline);

    return Dismissible(
      key: ValueKey(agenda),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RiveAnimatedIcon(
            riveIcon: RiveIcon.bin,
            width: 30,
            height: 30,
            color: Colors.white,
            strokeWidth: 3,
            loopAnimation: true,
            onTap: () {},
            onHover: (value) {}),
      ),
      secondaryBackground: Container(
        color: Colors.blue,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RiveAnimatedIcon(
            riveIcon: RiveIcon.edit,
            width: 30,
            height: 30,
            color: Colors.white,
            strokeWidth: 3,
            loopAnimation: true,
            onTap: () {},
            onHover: (value) {}),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {}
      },
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.4,
        DismissDirection.endToStart: 0.4,
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Delete action
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const CustomText(
                'Delete Agenda',
                fontSize: 18,
              ),
              content: const CustomText2(
                'Are you sure you want to delete this agenda?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const CustomText2(
                    'Cancel',
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const CustomText2(
                    'Delete',
                  ),
                ),
              ],
            ),
          );
        } else {
          // Edit action
          onEdit?.call();
          return false;
        }
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (showCheckbox)
                  Checkbox(
                    value: agenda.selected,
                    onChanged: (value) => onTap?.call(),
                  ),
                _buildStatusIndicator(context),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agenda.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          decoration:
                              agenda.status ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${agenda.deadline.day}/${agenda.deadline.month}/${agenda.deadline.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpired && !agenda.status
                                  ? Colors.red
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                            ),
                          ),
                          if (agenda.category != null &&
                              agenda.category!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                agenda.category!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: agenda.status,
                  onChanged: onStatusChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
