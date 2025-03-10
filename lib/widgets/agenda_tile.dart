import 'package:flutter/material.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import '../models/agenda_model.dart';
import 'agenda_details_modal.dart';
import 'custom_text.dart';

class AgendaTile extends StatelessWidget {
  final AgendaModel agenda;
  final Function(bool?) onStatusChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final bool showCheckbox;
  final Function()? onDelete;

  const AgendaTile({
    Key? key,
    required this.agenda,
    required this.onStatusChanged,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
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
    final isExpired = !agenda.status && now.isAfter(agenda.deadline);
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Dismissible(
      key: Key(agenda.title),
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: RiveAnimatedIcon(
          riveIcon: RiveIcon.edit,
          width: 24,
          height: 24,
          color: Colors.white,
          loopAnimation: true,
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: RiveAnimatedIcon(
          riveIcon: RiveIcon.bin,
          width: 24,
          height: 24,
          color: Colors.white,
          loopAnimation: true,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false;
        } else {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: CustomText('Delete Agenda'),
                content:
                    CustomText2('Are you sure you want to delete this agenda?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: CustomText2('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: CustomText2('Delete'),
                  ),
                ],
              );
            },
          );
          if (result == true) {
            onDelete?.call();
          }
          return false;
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isLightMode ? Colors.white : Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isLightMode
                  ? Colors.black.withOpacity(0.1)
                  : Colors.white.withOpacity(0.1),
              blurRadius: 25,
              spreadRadius: 3,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap ??
                () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AgendaDetailsModal(
                      agenda: agenda,
                      onComplete: () {
                        onStatusChanged?.call(true);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
            onLongPress: onLongPress,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  if (showCheckbox)
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        agenda.selected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isLightMode
                                    ? (agenda.selected
                                        ? Colors.black
                                        : Colors.grey[100])
                                    : (agenda.selected
                                        ? Colors.white
                                        : Colors.grey[800]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomText2(
                                agenda.category ?? 'Default',
                                fontSize: 12,
                                color: isLightMode
                                    ? (agenda.selected
                                        ? Colors.white
                                        : Colors.black)
                                    : (agenda.selected
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ),
                            Spacer(),
                            CustomText2(
                              _getTimeLeft(),
                              fontSize: 12,
                              color: _getTimeColor(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        CustomText(
                          agenda.title,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: agenda.status
                              ? isLightMode
                                  ? Colors.grey
                                  : Colors.grey[400]
                              : isLightMode
                                  ? Colors.black
                                  : Colors.white,
                          // Note: TextDecoration is not directly supported in CustomText
                          // We would need to extend CustomText to support this if needed
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeLeft() {
    final now = DateTime.now();
    final difference = agenda.deadline.difference(now);

    if (agenda.status) return 'Completed';
    if (difference.isNegative) return 'Expired';

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else {
      return '${difference.inMinutes}m left';
    }
  }

  Color _getTimeColor(BuildContext context) {
    if (agenda.status) return Colors.green;

    final now = DateTime.now();
    final difference = agenda.deadline.difference(now);

    if (difference.isNegative) return Colors.red;
    if (difference.inHours < 24) return Colors.orange;
    return Colors.orange;
  }
}
