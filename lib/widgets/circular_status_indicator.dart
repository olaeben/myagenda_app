import 'dart:math';
import 'package:flutter/material.dart';

class CircularStatusIndicator extends StatelessWidget {
  final Map<String, double> values;
  final double size;
  final double strokeWidth;

  const CircularStatusIndicator({
    Key? key,
    required this.values,
    this.size = 200,
    this.strokeWidth = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CircularStatusPainter(
          values: values,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class CircularStatusPainter extends CustomPainter {
  final Map<String, double> values;
  final double strokeWidth;

  CircularStatusPainter({
    required this.values,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width - strokeWidth) / 2;

    if (values.isEmpty || values.values.every((value) => value == 0)) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = Colors.grey.shade300;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: baseRadius),
        0,
        2 * pi,
        false,
        paint,
      );
      return;
    }

    double startAngle = pi / 2;
    final sortedEntries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    const double gapAngle = 0.02;

    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final radius = baseRadius - (i * strokeWidth * 0.2);
      final currentStrokeWidth =
          strokeWidth * (1 + (0.5 * (sortedEntries.length - i - 1)));

      final sweepAngle = (2 * pi * (entry.value / 100)) -
          (gapAngle * (sortedEntries.length - 1));
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = _getColor(entry.key.toLowerCase());

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle + gapAngle;
    }
  }

  Color _getColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
