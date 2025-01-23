import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

class MyAgendaTile extends StatefulWidget {
  final String myAgendaTitle;
  final bool myAgendaStatus;
  final DateTime deadline;
  final Function(bool?)? myAgendaStatusChanged;
  final Function(BuildContext)? delete;
  final Function(BuildContext)? edit;

  const MyAgendaTile({
    super.key,
    required this.myAgendaTitle,
    required this.myAgendaStatus,
    required this.deadline,
    required this.myAgendaStatusChanged,
    required this.delete,
    required this.edit,
  });

  @override
  State<MyAgendaTile> createState() => _MyAgendaTileState();
}

class _MyAgendaTileState extends State<MyAgendaTile> {
  late bool isAnimatingLeft;
  late bool isAnimatingRight;

  @override
  void initState() {
    super.initState();
    isAnimatingLeft = false;
    isAnimatingRight = false;
  }

  void _startAnimation(String direction) {
    if (direction == "left") {
      setState(() {
        isAnimatingLeft = true;
      });
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            isAnimatingLeft = false;
          });
        }
      });
    } else if (direction == "right") {
      setState(() {
        isAnimatingRight = true;
      });
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            isAnimatingRight = false;
          });
        }
      });
    }
  }

  String _getFormattedDeadline() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final deadlineDate = DateTime(
      widget.deadline.year,
      widget.deadline.month,
      widget.deadline.day,
    );

    if (deadlineDate.isBefore(today)) {
      return 'Expired';
    } else if (deadlineDate.isAtSameMomentAs(today)) {
      return 'Today ${DateFormat('HH:mm').format(widget.deadline)}';
    } else if (deadlineDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow ${DateFormat('HH:mm').format(widget.deadline)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(widget.deadline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final isExpired = DateTime.now().isAfter(widget.deadline);
    final isCompleted = widget.myAgendaStatus;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Dismissible(
          key: UniqueKey(),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RiveAnimatedIcon(
              riveIcon: RiveIcon.bin,
              width: 32,
              height: 32,
              color: Colors.black,
              loopAnimation: isAnimatingLeft,
            ),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RiveAnimatedIcon(
              riveIcon: RiveIcon.edit,
              width: 32,
              height: 32,
              color: Colors.black,
              loopAnimation: isAnimatingRight,
            ),
          ),
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.5,
            DismissDirection.endToStart: 0.5,
          },
          movementDuration: const Duration(milliseconds: 200),
          onUpdate: (details) {
            if (details.progress > 0 &&
                !isAnimatingLeft &&
                details.direction == DismissDirection.startToEnd) {
              _startAnimation("left");
            } else if (details.progress > 0 &&
                !isAnimatingRight &&
                details.direction == DismissDirection.endToStart) {
              _startAnimation("right");
            }
          },
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              widget.delete?.call(context);
            } else {
              widget.edit?.call(context);
            }
            return false; // Keep the item
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLightMode ? Colors.white : Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: isLightMode ? Colors.grey.shade300 : Colors.black54,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isCompleted,
                      onChanged: widget.myAgendaStatusChanged,
                      activeColor: isLightMode ? Colors.black87 : Colors.white,
                      checkColor: isLightMode ? Colors.white : Colors.black87,
                      side: BorderSide(
                        color: isLightMode ? Colors.black87 : Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.myAgendaTitle,
                        style: TextStyle(
                          color: isExpired && !isCompleted
                              ? Colors.red
                              : isLightMode
                                  ? Colors.black
                                  : Colors.white,
                          fontSize: 14,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Text(
                    _getFormattedDeadline(),
                    style: TextStyle(
                      color: isCompleted && !isExpired
                          ? Colors.green
                          : isExpired
                              ? Colors.red
                              : isLightMode
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
