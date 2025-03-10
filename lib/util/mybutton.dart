import 'package:flutter/material.dart';
import '../widgets/custom_text.dart';

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
      child: CustomText2(
        text,
        color: textColor,
      ),
    );
  }
}
