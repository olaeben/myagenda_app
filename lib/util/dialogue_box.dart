import 'package:flutter/material.dart';
import 'package:myagenda_app/util/mybutton.dart';

class DialogueBox extends StatefulWidget {
  final TextEditingController controller;
  const DialogueBox({super.key, required this.controller});

  @override
  State<DialogueBox> createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        height: 130,
        width: 300,
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                style: TextStyle(
                  color: isLightMode ? Colors.black : Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Agenda',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                cursorColor: isLightMode ? Colors.black : Colors.white,
              ),
            ),
            SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  text: 'Save',
                  textColor: isLightMode ? Colors.black : Colors.white,
                  onPressed: () {
                    if (widget.controller.text.trim().isNotEmpty) {
                      Navigator.of(context).pop(widget.controller.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Agenda cannot be empty'),
                        ),
                      );
                    }
                  },
                ),
                MyButton(
                  text: 'Cancel',
                  textColor: isLightMode ? Colors.black : Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
