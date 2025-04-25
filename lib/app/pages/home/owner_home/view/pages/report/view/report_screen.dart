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
  final GlobalKey _summaryCardKey = GlobalKey();

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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

  /// Build a summary card showing key metrics
  Widget _buildSummaryCard(ReportLoaded state) {
    // Calculate total sales, profits, and transactions
    final totalSales = state.salesLineChart.values.fold(0.0, (p, c) => p + c);
    final totalProfits =
        state.profitsLineChart.values.fold(0.0, (p, c) => p + c);
    final totalTransactions =
        state.transactionCountChart.values.fold(0.0, (p, c) => p + c);

    return RepaintBoundary(
      key: _summaryCardKey,
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Products Sold',
                    totalSales.toStringAsFixed(0),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Profits',
                    NumberFormat.currency(symbol: 'Rp', decimalDigits: 0)
                        .format(totalProfits),
                    Icons.attach_money,
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Transactions',
                    totalTransactions.toStringAsFixed(0),
                    Icons.receipt_long,
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Date Range: ${DateFormat('MMM dd, yyyy').format(state.startDate!)} - ${DateFormat('MMM dd, yyyy').format(state.endDate!)}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
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

    // Calculate dynamic bar width based on number of data points
    final int dataCount = entries.length;
    double barWidth = dataCount <= 7
        ? 16.0
        : dataCount <= 14
            ? 12.0
            : dataCount <= 21
                ? 8.0
                : 6.0;

    // Change back to diagonal rotation (45 degrees) instead of vertical (90 degrees)
    final bool shouldRotateLabels = dataCount > 7;
    final double labelRotation = shouldRotateLabels ? 45.0 : 0.0;

    // Adjust reserved space for diagonal labels
    final double bottomReservedSize = shouldRotateLabels ? 60.0 : 40.0;

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
              color: Colors.blue.shade700,
              width: barWidth,
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [Colors.blue.shade500, Colors.blue.shade900],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        ),
      );
      final label = isMonthlyGrouping
          ? DateFormat.MMM().format(date)
          : DateFormat.MMMd().format(date);
      dateLabels[i] = label;
    }
    final double interval = _computeInterval(dataMap);

    return RepaintBoundary(
      key: key,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: barGroups,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                          left:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: bottomReservedSize,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final label = dateLabels[value.toInt()] ?? '';
                              return SideTitleWidget(
                                meta: meta,
                                space: 8.0,
                                angle: labelRotation *
                                    3.14159 /
                                    180, // Convert to radians
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
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
                                space: 8.0,
                                child: Text(
                                  value.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
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
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (set) => Colors.blueAccent,
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final date = entries[group.x.toInt()].key;
                            final value = rod.toY;
                            String formattedDate = isMonthlyGrouping
                                ? DateFormat.yMMM().format(date)
                                : DateFormat.yMMMd().format(date);
                            return BarTooltipItem(
                              '$formattedDate\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: value.toStringAsFixed(0),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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
      Map<String, double> dataMap, String chartTitle) {
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
      Colors.blue.shade700,
      Colors.red.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.cyan.shade700,
      Colors.teal.shade700,
      Colors.pink.shade700,
      Colors.indigo.shade700,
      Colors.amber.shade700,
    ];

    return groupedData.entries.map((entry) {
      final percentage = total == 0 ? 0 : (entry.value / total * 100);
      final section = PieChartSectionData(
        value: entry.value,
        color: colors[i % colors.length],
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 75,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _Badge(
          entry.key,
          size: 50,
          borderColor: colors[i % colors.length],
          onTap: () {
            // Show dialog with full text when badge is clicked
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  chartTitle, // Use the passed chart title parameter
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.value.toStringAsFixed(0)} items (${percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        badgePositionPercentageOffset: 1.3,
      );
      i++;
      return section;
    }).toList();
  }

  /// Build a pie chart wrapped in its own RepaintBoundary.
  Widget _buildPieChart(String title, Map<String, double> dataMap,
      {required GlobalKey key}) {
    final sections =
        _createPieChartSections(dataMap, title); // Pass title parameter
    return RepaintBoundary(
      key: key,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    centerSpaceColor: Colors.white,
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

    // Add title and date to the first page
    final summaryBytes = await _captureChart(_summaryCardKey);
    final summaryImage = pw.MemoryImage(summaryBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Sales Analysis Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Image(summaryImage, fit: pw.BoxFit.contain),
              ),
            ],
          );
        },
      ),
    );

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
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Generating PDF..."),
                ],
              ),
            ),
          );
        },
      );

      final pdfData = await _generatePdfFromCharts();

      // Dismiss loading dialog
      Navigator.of(context).pop();

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'sales_report_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfData);
      await Share.shareXFiles([XFile(file.path)], text: 'Sales Report PDF');
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to generate PDF: ${e.toString()}'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      debugPrint('Error sharing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Add spacing at the top of the screen
            const SizedBox(height: 8),

            // Filter Controls.
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Date Range',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Colors.black), // Changed to black
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Colors.black), // Changed to black
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: const Icon(Icons.date_range),
                ),
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(
                      value: 'Last 7 Days', child: Text('Last 7 Days')),
                  DropdownMenuItem(
                      value: 'Last Month', child: Text('Last Month')),
                  DropdownMenuItem(
                      value: 'Last Year', child: Text('Last Year')),
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
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading report data...'),
                          ],
                        ),
                      );
                    } else if (state is ReportLoaded) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildSummaryCard(state),
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
                            const SizedBox(
                                height: 80), // Extra space at bottom for FAB
                          ],
                        ),
                      );
                    } else if (state is ReportError) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${state.message}',
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _applyFilter,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
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
      ),
      // Add FloatingActionButton for sharing
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sharePdf,
        tooltip: 'Share Report',
        icon: const Icon(Icons.share),
        label: const Text('Share Report'),
        elevation: 4,
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

// Badge widget for pie chart labels
class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;
  final VoidCallback? onTap;

  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: PieChart.defaultDuration,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.5),
              blurRadius: 3,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text.length > 10 ? '${text.substring(0, 10)}...' : text,
                style: TextStyle(
                  fontSize: size / 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (text.length > 10)
                Icon(
                  Icons.touch_app,
                  size: size / 7,
                  color: borderColor.withOpacity(0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
