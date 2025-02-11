import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final VoidCallback onPressed;

  const MyButton({
    required this.text,
    required this.textColor,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade400,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: textColor, fontFamily: 'Poppins'),
      ),
    );
  }
}
