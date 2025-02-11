import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w600,
    this.color,
    this.textAlign,
  });

  CustomText copyWith({
    String? text,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      color: color ?? this.color,
      textAlign: textAlign ?? this.textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ??
            (Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
      ),
      textAlign: textAlign,
    );
  }
}

class CustomText2 extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;

  const CustomText2(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w300,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ??
            (Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
      ),
      textAlign: textAlign,
    );
  }
}
