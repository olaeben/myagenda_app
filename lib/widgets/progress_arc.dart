import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'custom_text.dart';

class ProgressArc extends StatelessWidget {
  final double completedPercentage;
  final double pendingPercentage;
  final double expiredPercentage;

  const ProgressArc({
    Key? key,
    required this.completedPercentage,
    required this.pendingPercentage,
    required this.expiredPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(200, 200),
          painter: ProgressArcPainter(
            completedPercentage: completedPercentage,
            pendingPercentage: pendingPercentage,
            expiredPercentage: expiredPercentage,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(completedPercentage + pendingPercentage + expiredPercentage).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const CustomText('Completed'),
                const SizedBox(width: 16),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const CustomText('Pending'),
                const SizedBox(width: 16),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const CustomText('Expired'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ProgressArcPainter extends CustomPainter {
  final double completedPercentage;
  final double pendingPercentage;
  final double expiredPercentage;

  ProgressArcPainter({
    required this.completedPercentage,
    required this.pendingPercentage,
    required this.expiredPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    // Completed
    final completedSweepAngle = 2 * math.pi * (completedPercentage / 100);
    final completedPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      completedSweepAngle,
      false,
      completedPaint,
    );

    // Pending
    final pendingSweepAngle = 2 * math.pi * (pendingPercentage / 100);
    final pendingPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + completedSweepAngle,
      pendingSweepAngle,
      false,
      pendingPaint,
    );

    // Expired
    final expiredSweepAngle = 2 * math.pi * (expiredPercentage / 100);
    final expiredPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + completedSweepAngle + pendingSweepAngle,
      expiredSweepAngle,
      false,
      expiredPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressArcPainter oldDelegate) {
    return oldDelegate.completedPercentage != completedPercentage ||
        oldDelegate.pendingPercentage != pendingPercentage ||
        oldDelegate.expiredPercentage != expiredPercentage;
  }
}
