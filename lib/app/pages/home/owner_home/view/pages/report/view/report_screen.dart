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

  double _computeInterval(Map<DateTime, double> dataMap) {
    if (dataMap.isEmpty) return 1;
    final maxVal = dataMap.values.reduce((a, b) => a > b ? a : b);
    // Divide the max value into roughly 4 parts.
    double interval = (maxVal / 4).ceilToDouble();
    return interval < 1 ? 1 : interval;
  }

  /// Helper: Build a modern, animated bar chart using fl_chart.
  /// The [leftReservedSize] allows more space for left axis labels.
  Widget _buildBarChart(
      String title, Map<DateTime, double> dataMap, bool isMonthlyGrouping,
      {double leftReservedSize = 40}) {
    final entries = dataMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Create bar groups and mapping for bottom axis labels.
    final List<BarChartGroupData> barGroups = [];
    final Map<int, String> dateLabels = {};
    for (int i = 0; i < entries.length; i++) {
      final date = entries[i].key;
      final value = entries[i].value;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      // Format label based on the provided grouping flag.
      final label = isMonthlyGrouping
          ? DateFormat.MMM().format(date) // e.g., Jan, Feb, etc.
          : DateFormat.Md().format(date); // e.g., 3/15
      dateLabels[i] = label;
    }

    // Compute a dynamic interval if needed (or set a fixed one).
    final double interval = _computeInterval(dataMap);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barGroups,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final label = dateLabels[value.toInt()] ?? '';
                          return SideTitleWidget(
                            meta: meta,
                            space: 4.0,
                            child: Text(label,
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: leftReservedSize,
                        interval: interval,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 4.0,
                            child: Text(value.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
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
    // Calculate total for percentage computation.
    final total = dataMap.values.fold(0.0, (prev, element) => prev + element);

    // Threshold: if a slice is less than 5% of total, group it into "Others".
    const double thresholdPercentage = 5.0;
    final Map<String, double> groupedData = {};
    double othersTotal = 0.0;

    // Group the data.
    dataMap.forEach((key, value) {
      final percentage = total == 0 ? 0 : (value / total * 100);
      if (percentage < thresholdPercentage) {
        othersTotal += value;
      } else {
        groupedData[key] = value;
      }
    });

    if (othersTotal > 0) {
      groupedData['Others'] = othersTotal;
    }

    // Create pie chart sections from the grouped data.
    int i = 0;
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.teal,
    ];

    return groupedData.entries.map((entry) {
      final percentage = total == 0 ? 0 : (entry.value / total * 100);
      final section = PieChartSectionData(
        value: entry.value,
        color: colors[i % colors.length],
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
      i++;
      return section;
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
          children: [
            Center(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
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
                        _buildBarChart('Total Product Sold',
                            state.salesLineChart, state.isMonthlyGrouping),
                        _buildBarChart('Total Profits', state.profitsLineChart,
                            state.isMonthlyGrouping,
                            leftReservedSize: 60),
                        _buildBarChart(
                            'Number of Transactions',
                            state.transactionCountChart,
                            state.isMonthlyGrouping),
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
