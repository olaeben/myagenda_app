import 'dart:math';
import 'package:flutter/material.dart';
import '../models/agenda_model.dart';
import 'custom_text.dart';
import 'package:slide_to_act/slide_to_act.dart';

class AgendaDetailsModal extends StatelessWidget {
  final AgendaModel agenda;
  final VoidCallback onComplete;

  const AgendaDetailsModal({
    Key? key,
    required this.agenda,
    required this.onComplete,
  }) : super(key: key);

  String _getTimeLeft() {
    final now = DateTime.now();
    final difference = agenda.deadline.difference(now);

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
          children: [
            Center(
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
                    children: [
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isLightMode
                                ? Colors.grey[400]!
                                : Colors.grey[600]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          agenda.category ?? 'Default',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isLightMode ? Colors.black54 : Colors.white70,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        agenda.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black : Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Time Left',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: isLightMode ? Colors.black54 : Colors.white70,
                        ),
                      ),
                      Text(
                        _getTimeLeft(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isLightMode ? Colors.black : Colors.white,
                        ),
                      ),
                      Text(
                        _formatDate(agenda.deadline),
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black54 : Colors.white70,
                        ),
                      ),
                      SizedBox(height: 20),
                      if (agenda.description != null &&
                          agenda.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                fontFamily: "Poppins",
                                color: isLightMode
                                    ? Colors.black54
                                    : Colors.white70,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                agenda.description!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Poppins',
                                  color:
                                      isLightMode ? Colors.black : Colors.white,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      Text(
                        'Created on',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: isLightMode ? Colors.black54 : Colors.white70,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        _formatDate(agenda.createdAt ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black54 : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Slide action remains at the bottom
            if (!agenda.status)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SlideAction(
                  text: 'Slide to Complete',
                  textStyle: TextStyle(
                    color: isLightMode ? Colors.black54 : Colors.white70,
                    fontSize: 16,
                    fontFamily: "Poppins",
                  ),
                  outerColor: isLightMode ? Colors.grey[100] : Colors.grey[700],
                  innerColor:
                      isLightMode ? Colors.brown[500] : Colors.brown[700],
                  sliderButtonIcon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onSubmit: () {
                    onComplete();
                    Future.delayed(Duration(milliseconds: 300), () {
                      Navigator.pop(context);
                    });
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
