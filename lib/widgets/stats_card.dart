import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'custom_progress_indicator.dart';
import 'custom_text.dart';

class StatsCard extends StatelessWidget {
  final int totalAgendas;
  final double completedPercentage;
  final double pendingPercentage;
  final double expiredPercentage;

  const StatsCard({
    Key? key,
    required this.totalAgendas,
    required this.completedPercentage,
    required this.pendingPercentage,
    required this.expiredPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Progress Circle
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  CustomProgressIndicator(
                    completedPercentage: completedPercentage,
                    pendingPercentage: pendingPercentage,
                    expiredPercentage: expiredPercentage,
                  ),
                ],
              ),
            ),
            // Stats Breakdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: $totalAgendas tasks',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildStatRow(
                  'Completed',
                  '${(completedPercentage * totalAgendas / 100).round()}/$totalAgendas',
                  Colors.green,
                ),
                _buildStatRow(
                  'Pending',
                  '${(pendingPercentage * totalAgendas / 100).round()}/$totalAgendas',
                  Colors.orange,
                ),
                _buildStatRow(
                  'Expired',
                  '${(expiredPercentage * totalAgendas / 100).round()}/$totalAgendas',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
