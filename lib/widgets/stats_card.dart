import 'package:flutter/material.dart';
import 'circular_status_indicator.dart';

class StatsCard extends StatefulWidget {
  final int totalAgendas;
  final double completedPercentage;
  final double pendingPercentage;
  final double expiredPercentage;
  final Function(List<String>)? onStatusFilterChanged;
  final List<String> selectedStatuses;

  const StatsCard({
    Key? key,
    required this.totalAgendas,
    required this.completedPercentage,
    required this.pendingPercentage,
    required this.expiredPercentage,
    this.onStatusFilterChanged,
    this.selectedStatuses = const [],
  }) : super(key: key);

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  late List<String> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _selectedStatuses = List.from(widget.selectedStatuses);
  }

  @override
  void didUpdateWidget(StatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedStatuses != widget.selectedStatuses) {
      _selectedStatuses = List.from(widget.selectedStatuses);
    }
  }

  void _toggleStatus(String status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }

      if (widget.onStatusFilterChanged != null) {
        widget.onStatusFilterChanged!(_selectedStatuses);
      }
    });
  }

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

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white : Colors.grey[850],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: isLightMode
                ? Colors.black.withAlpha((0.1 * 255).round())
                : Colors.white.withAlpha((0.1 * 255).round()),
            blurRadius: 15,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: isLightMode ? Colors.black87 : Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLightMode ? Colors.grey[100] : Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.totalAgendas} Agenda(s)',
                    style: TextStyle(
                      color: isLightMode ? Colors.black54 : Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        CircularStatusIndicator(
                          values: widget.totalAgendas == 0
                              ? {'Empty': 100}
                              : {
                                  'Completed': widget.completedPercentage,
                                  'Pending': widget.pendingPercentage,
                                  'Expired': widget.expiredPercentage,
                                },
                          size: double.infinity,
                          strokeWidth: 12,
                          emptyColor: isLightMode
                              ? Colors.grey[200]!
                              : Colors.grey[700]!,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _buildStatItem(
                        context,
                        label: 'Completed',
                        value: widget.completedPercentage,
                        count: (widget.completedPercentage *
                                widget.totalAgendas /
                                100)
                            .round(),
                        color: Colors.green,
                        isSelected: _selectedStatuses.contains('completed'),
                        onTap: () => _toggleStatus('completed'),
                      ),
                      SizedBox(height: 16),
                      _buildStatItem(
                        context,
                        label: 'Pending',
                        value: widget.pendingPercentage,
                        count: (widget.pendingPercentage *
                                widget.totalAgendas /
                                100)
                            .round(),
                        color: Colors.orange,
                        isSelected: _selectedStatuses.contains('pending'),
                        onTap: () => _toggleStatus('pending'),
                      ),
                      SizedBox(height: 16),
                      _buildStatItem(
                        context,
                        label: 'Expired',
                        value: widget.expiredPercentage,
                        count: (widget.expiredPercentage *
                                widget.totalAgendas /
                                100)
                            .round(),
                        color: Colors.red,
                        isSelected: _selectedStatuses.contains('expired'),
                        onTap: () => _toggleStatus('expired'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required double value,
    required int count,
    required Color color,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final displayColor =
        _selectedStatuses.isEmpty || isSelected ? color : Colors.grey;
    final backgroundColor = _selectedStatuses.isEmpty || isSelected
        ? color.withAlpha((0.2 * 255).round())
        : Colors.grey.withAlpha((0.1 * 255).round());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: displayColor, width: 2),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isLightMode ? Colors.black87 : Colors.white,
                        ),
                      ),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      backgroundColor: backgroundColor,
                      valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
