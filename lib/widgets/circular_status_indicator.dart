import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CircularStatusIndicator extends StatefulWidget {
  final Map<String, double> values;
  final double size;
  final double strokeWidth;
  final Color? emptyColor;

  const CircularStatusIndicator(
      {Key? key,
      required this.values,
      this.emptyColor,
      this.size = 200,
      this.strokeWidth = 30})
      : super(key: key);

  @override
  State<CircularStatusIndicator> createState() =>
      _CircularStatusIndicatorState();
}

class _CircularStatusIndicatorState extends State<CircularStatusIndicator> {
  ChartData? selectedData;
  int? explodeIndex;

  @override
  void initState() {
    super.initState();
    selectedData = null;
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final chartData = widget.values.isEmpty
        ? [ChartData('Empty', 0.0, Colors.grey)]
        : widget.values.entries
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: isLightMode
                            ? Colors.brown.shade800
                            : Colors.brown.shade100,
                      ),
                    )
                  : Container(),
            ),
          ),
        ],
        series: <CircularSeries>[
          DoughnutSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.status,
            yValueMapper: (ChartData data, _) => data.value,
            pointColorMapper: (ChartData data, _) => data.color,
            innerRadius: '60%',
            explode: true,
            explodeIndex: explodeIndex,
            explodeOffset: '10%',
            strokeWidth: widget.strokeWidth,
            radius: '100%',
            onPointTap: (ChartPointDetails details) {
              setState(() {
                if (explodeIndex == details.pointIndex) {
                  // When clicking the same segment again, reset to 0.0%
                  selectedData = null;
                  explodeIndex = null;
                } else {
                  if (chartData.length == 1 && chartData[0].status == 'Empty') {
                    selectedData = ChartData('Empty', 0.0, Colors.grey);
                    explodeIndex = 0;
                  } else if (details.pointIndex != null &&
                      details.pointIndex! < chartData.length) {
                    selectedData = chartData[details.pointIndex!];
                    explodeIndex = details.pointIndex;
                  }
                }
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
