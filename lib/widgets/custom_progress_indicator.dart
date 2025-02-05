import 'dart:math';
import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatefulWidget {
  final double completedPercentage;
  final double pendingPercentage;
  final double expiredPercentage;
  final double size;

  const CustomProgressIndicator({
    Key? key,
    required this.completedPercentage,
    required this.pendingPercentage,
    required this.expiredPercentage,
    this.size = 200,
  }) : super(key: key);

  @override
  State<CustomProgressIndicator> createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: ProgressPainter(
          completed: widget.completedPercentage,
          pending: widget.pendingPercentage,
          expired: widget.expiredPercentage,
          isLightMode: isLightMode,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ProgressPainter extends CustomPainter {
  final double completed;
  final double pending;
  final double expired;
  final bool isLightMode;

  ProgressPainter({
    required this.completed,
    required this.pending,
    required this.expired,
    required this.isLightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    paint.color = Colors.grey.withOpacity(0.2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth),
      -pi / 2,
      2 * pi,
      false,
      paint,
    );

    // Draw progress arcs
    final total = completed + pending + expired;
    var startAngle = -pi / 2;

    // Completed
    if (completed > 0) {
      paint.color = Colors.green;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth),
        startAngle,
        (completed / total) * 2 * pi,
        false,
        paint,
      );
      startAngle += (completed / total) * 2 * pi;
    }

    // Pending
    if (pending > 0) {
      paint.color = Colors.amber;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth),
        startAngle,
        (pending / total) * 2 * pi,
        false,
        paint,
      );
      startAngle += (pending / total) * 2 * pi;
    }

    // Expired
    if (expired > 0) {
      paint.color = Colors.red;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth),
        startAngle,
        (expired / total) * 2 * pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
