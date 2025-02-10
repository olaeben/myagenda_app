import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CircularStatusIndicator extends StatefulWidget {
  final Map<String, double> values;
  final double size;
  final double strokeWidth;

  const CircularStatusIndicator(
      {Key? key, required this.values, this.size = 200, this.strokeWidth = 30})
      : super(key: key);

  @override
  State<CircularStatusIndicator> createState() =>
      _CircularStatusIndicatorState();
}

class _CircularStatusIndicatorState extends State<CircularStatusIndicator> {
  ChartData? selectedData;
  int? explodeIndex;

  @override
  Widget build(BuildContext context) {
    final chartData = widget.values.entries
        .map((entry) => ChartData(
            entry.key,
            double.parse(entry.value.toStringAsFixed(1)),
            _getStatusColor(entry.key)))
        .toList();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        annotations: [
          CircularChartAnnotation(
            widget: Center(
              child: selectedData != null
                  ? Text(
                      '${selectedData!.value.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
        series: <CircularSeries>[
          DoughnutSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.status,
            yValueMapper: (ChartData data, _) => data.value,
            pointColorMapper: (ChartData data, _) => data.color,
            innerRadius: '55%',
            explode: true,
            explodeIndex: explodeIndex,
            explodeOffset: '10%',
            strokeWidth: widget.strokeWidth,
            radius: '100%',
            onPointTap: (ChartPointDetails details) {
              setState(() {
                selectedData = chartData[details.pointIndex!];
                explodeIndex = details.pointIndex;
              });
            },
          )
        ],
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

class ChartData {
  final String status;
  final double value;
  final Color color;
  bool isSelected;

  ChartData(this.status, this.value, this.color, {this.isSelected = false});
}
