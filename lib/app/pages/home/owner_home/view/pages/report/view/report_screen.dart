import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/report/bloc/report_bloc.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedFilter = 'Last 7 Days';
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    _applyFilter();
  }

  void _applyFilter() {
    DateTime endDate = DateTime.now();
    DateTime? startDate;

    if (_selectedFilter == 'Last 7 Days') {
      startDate = endDate.subtract(const Duration(days: 7));
    } else if (_selectedFilter == 'Last Month') {
      startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
    } else if (_selectedFilter == 'Last Year') {
      startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
    } else if (_selectedFilter == 'Custom') {
      startDate = _customStart;
      endDate = _customEnd ?? endDate;
    }
    context
        .read<ReportBloc>()
        .add(LoadReportEvent(startDate: startDate, endDate: endDate));
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _customStart = picked.start;
        _customEnd = picked.end;
      });
      _applyFilter();
    }
  }

  /// Helper: Convert the aggregated Map<DateTime, double> into a list of FlSpot.
  List<FlSpot> _createLineChartSpots(Map<DateTime, double> dataMap) {
    final spots = <FlSpot>[];
    if (dataMap.isEmpty) return spots;
    final entries = dataMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final baseDate = entries.first.key;
    for (var entry in entries) {
      // x-axis: number of days since baseDate
      final x = entry.key.difference(baseDate).inDays.toDouble();
      spots.add(FlSpot(x, entry.value));
    }
    return spots;
  }

  /// Build a modern, animated line chart using fl_chart.
  Widget _buildLineChart(String title, Map<DateTime, double> dataMap) {
    final spots = _createLineChartSpots(dataMap);
    if (spots.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    final sortedDates = dataMap.keys.toList()..sort();
    final firstDate = sortedDates.first;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: const LineTouchData(
                    touchTooltipData: LineTouchTooltipData(),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          // Convert days offset back to date
                          DateTime date =
                              firstDate.add(Duration(days: value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(DateFormat.Md().format(date),
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  minX: spots.first.x,
                  maxX: spots.last.x,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.blue,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.3)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Create pie chart sections from a Map<String, double>.
  List<PieChartSectionData> _createPieChartSections(
      Map<String, double> dataMap) {
    final total = dataMap.values.fold(0.0, (prev, element) => prev + element);
    int i = 0;
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];
    return dataMap.entries.map((entry) {
      final percentage = total == 0 ? 0 : (entry.value / total * 100);
      return PieChartSectionData(
        value: entry.value,
        color: colors[i++ % colors.length],
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  /// Build a modern, animated pie chart using fl_chart.
  Widget _buildPieChart(String title, Map<String, double> dataMap) {
    final sections = _createPieChartSections(dataMap);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
      ),
      body: Column(
        children: [
          // Filter Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedFilter,
                    items: const [
                      'Last 7 Days',
                      'Last Month',
                      'Last Year',
                      'Custom'
                    ]
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFilter = value;
                        });
                        if (value == 'Custom') {
                          _selectCustomDateRange();
                        } else {
                          _applyFilter();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReportLoaded) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // For "Total Sales", ensure aggregation uses quantity (update in ReportBloc accordingly)
                        _buildLineChart('Total Sales', state.salesLineChart),
                        _buildLineChart(
                            'Total Profits', state.profitsLineChart),
                        _buildPieChart(
                            'Sales by Product Brand', state.brandPieChart),
                        _buildPieChart('Sales by Product Category',
                            state.categoryPieChart),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                } else if (state is ReportError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
