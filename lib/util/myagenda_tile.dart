import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyAgendaTile extends StatelessWidget {
  final String myAgendaTitle;
  final bool myAgendaStatus;
  final Function(bool?)? myAgendaStatusChanged;
  final Function(BuildContext)? delete;
  final Function(BuildContext)? edit;

  const MyAgendaTile({
    super.key,
    required this.myAgendaTitle,
    required this.myAgendaStatus,
    required this.myAgendaStatusChanged,
    required this.delete,
    required this.edit,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: edit,
              backgroundColor: Colors.grey.shade600,
              foregroundColor: isLightMode ? Colors.black : Colors.white,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(10),
            ),
            SlidableAction(
              onPressed: delete,
              backgroundColor: Colors.red,
              foregroundColor: isLightMode ? Colors.black : Colors.white,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLightMode ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isLightMode ? Colors.grey.shade300 : Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: Row(
            children: [
              Checkbox(
                value: myAgendaStatus,
                onChanged: myAgendaStatusChanged,
                activeColor: isLightMode ? Colors.black : Colors.white,
                checkColor: isLightMode ? Colors.white : Colors.black,
                side: BorderSide(
                    color: isLightMode ? Colors.black : Colors.white),
              ),
              Flexible(
                child: Text(
                  myAgendaTitle,
                  style: TextStyle(
                    color: isLightMode ? Colors.black : Colors.white,
                    fontSize: 14,
                    decoration: myAgendaStatus
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
