import 'package:flutter/material.dart';
import '../models/agenda_model.dart';
import 'package:slide_to_act/slide_to_act.dart';

import 'custom_text.dart';

class AgendaDetailsModal extends StatefulWidget {
  final AgendaModel agenda;
  final VoidCallback onComplete;

  const AgendaDetailsModal({
    Key? key,
    required this.agenda,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<AgendaDetailsModal> createState() => _AgendaDetailsModalState();
}

class _AgendaDetailsModalState extends State<AgendaDetailsModal> {
  String _getTimeLeft() {
    final now = DateTime.now();
    final difference = widget.agenda.deadline.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _handleComplete() {
    widget.onComplete();
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isLightMode ? Colors.white : Colors.grey[850],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
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
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isLightMode
                                ? Colors.grey[400]!
                                : Colors.grey[600]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        // Using intrinsic width instead of full width
                        width: null, // This allows the container to size to its content
                        child: CustomText2(
                          widget.agenda.category ?? 'Default',
                          fontSize: 13,
                          color: isLightMode ? Colors.black54 : Colors.white70,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          widget.agenda.title,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black : Colors.white,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: CustomText2(
                          'Time Left',
                          fontSize: 13,
                          color: isLightMode ? Colors.black54 : Colors.white70,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          _getTimeLeft(),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black : Colors.white,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: CustomText2(
                          _formatDate(widget.agenda.deadline),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black54 : Colors.white70,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 20),
                      if (widget.agenda.description != null &&
                          widget.agenda.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: CustomText2(
                                'Description',
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color:
                                    isLightMode ? Colors.black54 : Colors.white70,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: CustomText2(
                                widget.agenda.description!,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color:
                                    isLightMode ? Colors.black : Colors.white,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: CustomText2(
                          'Created on',
                          fontSize: 13,
                          color: isLightMode ? Colors.black54 : Colors.white70,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: CustomText2(
                          _formatDate(widget.agenda.createdAt ?? DateTime.now()),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black54 : Colors.white70,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!widget.agenda.status)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SlideAction(
                  text: '>> Swipe to Complete >>',
                  textStyle: TextStyle(
                    color: isLightMode ? Colors.black54 : Colors.white70,
                    fontSize: 16,
                    fontFamily: "Poppins",
                  ),
                  alignment: Alignment.center,
                  outerColor: isLightMode ? Colors.grey[100] : Colors.grey[700],
                  innerColor: isLightMode ? Colors.black : Colors.white,
                  sliderButtonIcon: Icon(
                    Icons.check,
                    color: isLightMode ? Colors.white : Colors.black,
                  ),
                  onSubmit: () {
                    _handleComplete();
                    return Future.value(false);
                  },
                ),
              ),
            SizedBox(height: 16)
          ],
        ),
      ),
    );
  }
}
