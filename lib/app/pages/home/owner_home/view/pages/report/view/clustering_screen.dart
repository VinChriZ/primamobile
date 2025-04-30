import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/report/bloc/clustering/clustering_bloc.dart';

class ClusteringScreen extends StatefulWidget {
  const ClusteringScreen({super.key});

  @override
  State<ClusteringScreen> createState() => _ClusteringScreenState();
}

class _ClusteringScreenState extends State<ClusteringScreen> {
  int _selectedYear = DateTime.now().year;
  int _numberOfClusters = 3;
  final int _currentYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Product Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Options',
          ),
        ],
      ),
      body: BlocBuilder<ClusteringBloc, ClusteringState>(
        builder: (context, state) {
          if (state is ClusteringInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClusteringLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing product sales patterns...'),
                ],
              ),
            );
          } else if (state is ClusteringLoaded) {
            return _buildClusteringContent(state);
          } else if (state is ClusteringError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClusteringBloc>().add(
                            LoadClusteringEvent(
                              startDate: state.startDate,
                              endDate: state.endDate,
                              numberOfClusters: state.numberOfClusters,
                            ),
                          );
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildClusteringContent(ClusteringLoaded state) {
    // Format to show only the year
    String yearText = 'Year: ${state.startDate!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with info section
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Product Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      yearText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'This analysis uses K-means clustering to identify product sales patterns:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildLegendItem(Colors.green[700]!,
                  'Best Selling Products: High sales volume and consistency'),
              const SizedBox(height: 4),
              _buildLegendItem(Colors.amber[700]!,
                  'Seasonal Products: Moderate or inconsistent sales'),
              const SizedBox(height: 4),
              _buildLegendItem(Colors.red[700]!,
                  'Low Selling Products: Low sales performance'),
            ],
          ),
        ),

        // Clusters list
        Expanded(
          child: state.groupedClusters.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bar_chart_outlined,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No product clustering data available',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: state.groupedClusters.length,
                  itemBuilder: (context, index) {
                    final clusterId =
                        state.groupedClusters.keys.elementAt(index);
                    final clusterProducts = state.groupedClusters[clusterId]!;
                    final clusterLabel =
                        state.clusterLabels[clusterId] ?? 'Cluster $clusterId';
                    final clusterColor =
                        state.clusterColors[clusterId] ?? Colors.blue;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildClusterSection(
                        clusterLabel,
                        clusterColor,
                        clusterProducts,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
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
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildClusterSection(
      String clusterLabel, Color clusterColor, List<ProductCluster> products) {
    // Sort products by total sales in descending order within each cluster
    products.sort((a, b) => b.totalSales.compareTo(a.totalSales));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: clusterColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              clusterLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: clusterColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${products.length} products)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        collapsedBackgroundColor: clusterColor.withOpacity(0.05),
        backgroundColor: clusterColor.withOpacity(0.05),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductsDataTable(products),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsDataTable(List<ProductCluster> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowHeight: 48,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
        columns: const [
          DataColumn(
              label: Text('Product Name',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Total Sales',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Days Sold',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Avg Daily',
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: products.map((product) {
          return DataRow(
            cells: [
              DataCell(
                FutureBuilder<String>(
                  future: _getProductName(product.upc),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      );
                    } else {
                      return Text(
                        product.upc,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      );
                    }
                  },
                ),
              ),
              DataCell(Text(product.totalSales.toStringAsFixed(0))),
              DataCell(Text(product.daysSold.toString())),
              DataCell(Text(product.avgDailySales.toStringAsFixed(1))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<String> _getProductName(String upc) async {
    final productRepo = context.read<ClusteringBloc>().productRepository;
    try {
      final product = await productRepo.fetchProduct(upc);
      return product.name;
    } catch (e) {
      return upc;
    }
  }

  void _showFilterDialog() async {
    final currentState = context.read<ClusteringBloc>().state;
    // Store the bloc reference before showing dialog
    final clusteringBloc = context.read<ClusteringBloc>();

    setState(() {
      _selectedYear = currentState.startDate?.year ?? _currentYear;
      _numberOfClusters = currentState.numberOfClusters;
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 24),
                  const SizedBox(width: 8),
                  const Text('Filter Options'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Select Year:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    value: _selectedYear,
                    items:
                        List.generate(10, (index) => _currentYear - 9 + index)
                            .map((year) => DropdownMenuItem<int>(
                                  value: year,
                                  child: Text('$year'),
                                ))
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Number of clusters:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('2'),
                      Expanded(
                        child: Slider(
                          min: 2,
                          max: 5,
                          divisions: 3,
                          label: _numberOfClusters.toString(),
                          value: _numberOfClusters.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _numberOfClusters = value.toInt();
                            });
                          },
                        ),
                      ),
                      const Text('5'),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'K = $_numberOfClusters clusters',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    // Set date range for the entire selected year
                    final startDate = DateTime(_selectedYear, 1, 1);
                    final endDate = DateTime(_selectedYear, 12, 31);

                    // Use the stored bloc reference instead of context.read
                    clusteringBloc.add(
                      ChangeClusteringFilterEvent(
                        startDate: startDate,
                        endDate: endDate,
                        numberOfClusters: _numberOfClusters,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
