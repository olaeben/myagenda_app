import 'package:flutter/material.dart';
import 'circular_status_indicator.dart';

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

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  CircularStatusIndicator(
                    values: totalAgendas == 0
                        ? {'Empty': 100}
                        : {
                            'Completed': completedPercentage,
                            'Pending': pendingPercentage,
                            'Expired': expiredPercentage,
                          },
                    size: 120,
                    strokeWidth: 15,
                    emptyColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: $totalAgendas Agendas',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: isLightMode
                        ? Colors.brown.shade800
                        : Colors.brown.shade100,
                  ),
                ),
                const SizedBox(height: 8),
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
}
