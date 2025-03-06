import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/report/bloc/report_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // Global keys for each chart.
  final GlobalKey _barChartKey1 = GlobalKey();
  final GlobalKey _barChartKey2 = GlobalKey();
  final GlobalKey _barChartKey3 = GlobalKey();
  final GlobalKey _pieChartKey1 = GlobalKey();
  final GlobalKey _pieChartKey2 = GlobalKey();

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
    double interval = (maxVal / 4).ceilToDouble();
    return interval < 1 ? 1 : interval;
  }

  /// Build a bar chart wrapped in its own RepaintBoundary.
  Widget _buildBarChart(
      String title, Map<DateTime, double> dataMap, bool isMonthlyGrouping,
      {double leftReservedSize = 40, required GlobalKey key}) {
    final entries = dataMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return const Center(child: Text('No data available'));
    }

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
      final label = isMonthlyGrouping
          ? DateFormat.MMM().format(date)
          : DateFormat.Md().format(date);
      dateLabels[i] = label;
    }
    final double interval = _computeInterval(dataMap);

    return RepaintBoundary(
      key: key,
      child: Card(
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
      ),
    );
  }

  /// Helper to create pie chart sections.
  List<PieChartSectionData> _createPieChartSections(
      Map<String, double> dataMap) {
    final total = dataMap.values.fold(0.0, (prev, element) => prev + element);
    const double thresholdPercentage = 5.0;
    final Map<String, double> groupedData = {};
    double othersTotal = 0.0;

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

  /// Build a pie chart wrapped in its own RepaintBoundary.
  Widget _buildPieChart(String title, Map<String, double> dataMap,
      {required GlobalKey key}) {
    final sections = _createPieChartSections(dataMap);
    return RepaintBoundary(
      key: key,
      child: Card(
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
      ),
    );
  }

  /// Capture the widget referenced by [key] as a PNG image.
  Future<Uint8List> _captureChart(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing chart: $e");
      rethrow;
    }
  }

  /// Generate a PDF where each chart is placed on its own page.
  Future<Uint8List> _generatePdfFromCharts() async {
    final pdf = pw.Document();
    const pageFormat = PdfPageFormat.a4;
    const margin = 20.0;

    // Order of charts as they appear in the report.
    final List<GlobalKey> chartKeys = [
      _barChartKey1,
      _barChartKey2,
      _barChartKey3,
      _pieChartKey1,
      _pieChartKey2,
    ];

    for (var key in chartKeys) {
      final imageBytes = await _captureChart(key);
      final pdfImage = pw.MemoryImage(imageBytes);
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(margin),
              child: pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              ),
            );
          },
        ),
      );
    }
    return pdf.save();
  }

  /// Share the generated PDF.
  void _sharePdf() async {
    try {
      final pdfData = await _generatePdfFromCharts();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sales_report.pdf');
      await file.writeAsBytes(pdfData);
      await Share.shareXFiles([XFile(file.path)], text: 'Sales Report PDF');
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
            tooltip: 'Share as PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Controls.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Date Range',
                border: OutlineInputBorder(),
              ),
              value: _selectedFilter,
              items: const [
                DropdownMenuItem(
                    value: 'Last 7 Days', child: Text('Last 7 Days')),
                DropdownMenuItem(
                    value: 'Last Month', child: Text('Last Month')),
                DropdownMenuItem(value: 'Last Year', child: Text('Last Year')),
                DropdownMenuItem(value: 'Custom', child: Text('Custom')),
              ],
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _applyFilter();
              },
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  if (state is ReportLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ReportLoaded) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildBarChart(
                            'Total Product Sold',
                            state.salesLineChart,
                            state.isMonthlyGrouping,
                            leftReservedSize: 40,
                            key: _barChartKey1,
                          ),
                          _buildBarChart(
                            'Total Profits',
                            state.profitsLineChart,
                            state.isMonthlyGrouping,
                            leftReservedSize: 60,
                            key: _barChartKey2,
                          ),
                          _buildBarChart(
                            'Number of Transactions',
                            state.transactionCountChart,
                            state.isMonthlyGrouping,
                            key: _barChartKey3,
                          ),
                          _buildPieChart(
                            'Sales by Product Brand',
                            state.brandPieChart,
                            key: _pieChartKey1,
                          ),
                          _buildPieChart(
                            'Sales by Product Category',
                            state.categoryPieChart,
                            key: _pieChartKey2,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  } else if (state is ReportError) {
                    // Ensure a scrollable widget is returned to enable pull-to-refresh.
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 300,
                        child: Center(
                          child: Text('Error: ${state.message}'),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
