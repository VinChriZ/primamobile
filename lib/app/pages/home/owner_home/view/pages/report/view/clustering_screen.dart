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
  final int _numberOfClusters = 3; // Fixed value of 3
  final int _currentYear = DateTime.now().year;
  List<int> _availableYears = []; // Years with complete data

  // Control whether to show all items or just top 10
  final Map<int, bool> _showAllItems = {};

  @override
  void initState() {
    super.initState();
    _fetchAvailableYearsAndInitialize();
  }

  // Fetch years with complete data and initialize with the latest year
  Future<void> _fetchAvailableYearsAndInitialize() async {
    try {
      final classificationRepo =
          context.read<ClusteringBloc>().classificationRepository;
      // Fetch years with complete data from January to December
      final years = await classificationRepo.fetchYearsWithCompleteData();
      setState(() {
        if (years.isNotEmpty) {
          // Make sure years list has no duplicates
          _availableYears = years.toSet().toList()..sort();
          // Use the most recent year with data as default
          _selectedYear = _availableYears.last;

          // Load data for the most recent year with complete data
          _loadDataForYear(_selectedYear);
        } else {
          // Fallback to current year if no years with complete data
          _availableYears = [_currentYear];
          _selectedYear = _currentYear;
          print('No years with complete data found, using current year');

          // Load data for current year as fallback
          _loadDataForYear(_currentYear);
        }
      });
    } catch (e) {
      // Fallback to current year if unable to fetch
      setState(() {
        _availableYears = [_currentYear];
        _selectedYear = _currentYear;
        print('Error fetching years with complete data: $e');

        // Load data for current year as fallback
        _loadDataForYear(_currentYear);
      });
    }
  }

  // Helper method to load data for a specific year
  void _loadDataForYear(int year) {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    context.read<ClusteringBloc>().add(
          LoadClusteringEvent(
            startDate: startDate,
            endDate: endDate,
            numberOfClusters: _numberOfClusters,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ClusteringBloc, ClusteringState>(
          builder: (context, state) {
            if (state is ClusteringLoaded && state.startDate != null) {
              return Text('Product Analysis ${state.startDate!.year}');
            }
            return const Text('Product Analysis');
          },
        ),
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
          } else if (state is ClusteringTrainingModel) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Training Classification Model...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This process will take a few moments.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'The model will identify product categories automatically.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          } else if (state is ClusteringModelTrained) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 60, color: Colors.green[700]),
                  const SizedBox(height: 16),
                  const Text(
                    'Model Training Completed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Loading results...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const CircularProgressIndicator(strokeWidth: 2),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      const SizedBox(width: 12),
                      if (state.message.contains('model needs to be trained'))
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            context.read<ClusteringBloc>().add(
                                  const RetrainModelEvent(),
                                );
                          },
                          icon: const Icon(Icons.model_training),
                          label: const Text('Train Model'),
                        ),
                    ],
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
    // Reset the show all items map when loading new data
    if (_showAllItems.length != state.groupedClusters.length) {
      _showAllItems.clear();
      for (var clusterId in state.groupedClusters.keys) {
        _showAllItems[clusterId] = false;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Train Model Elevated Button at top
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ElevatedButton.icon(
            onPressed: () => _showTrainModelConfirmation(context),
            icon: const Icon(Icons.model_training),
            label: const Text('Train Classification Model'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
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
                    // Define preferred order for cluster display: Green (best seller), Amber (seasonal), Red (low seller)
                    final preferredOrder = <Color>[
                      Colors.green[700]!,
                      Colors.amber[700]!,
                      Colors.red[700]!,
                    ];

                    // Get all cluster IDs and sort them based on the preferred color order
                    final sortedClusterIds = state.groupedClusters.keys.toList()
                      ..sort((a, b) {
                        final colorA = state.clusterColors[a] ?? Colors.blue;
                        final colorB = state.clusterColors[b] ?? Colors.blue;
                        return preferredOrder.indexOf(colorA) -
                            preferredOrder.indexOf(colorB);
                      });

                    final clusterId = sortedClusterIds[index];
                    final clusterProducts = state.groupedClusters[clusterId]!;
                    final clusterLabel =
                        state.clusterLabels[clusterId] ?? 'Cluster $clusterId';
                    final clusterColor =
                        state.clusterColors[clusterId] ?? Colors.blue;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildClusterSection(
                        clusterId,
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

  void _showTrainModelConfirmation(BuildContext context) {
    final clusteringState = context.read<ClusteringBloc>().state;
    // Store the bloc reference before showing dialog
    final clusteringBloc = context.read<ClusteringBloc>();

    DateTime? startDate, endDate;

    if (clusteringState is ClusteringLoaded) {
      startDate = clusteringState.startDate;
      endDate = clusteringState.endDate;
    }

    // Format dates for display
    final startText = startDate != null
        ? '${startDate.day}/${startDate.month}/${startDate.year}'
        : 'selected period';
    final endText = endDate != null
        ? '${endDate.day}/${endDate.month}/${endDate.year}'
        : '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.model_training, size: 24),
              SizedBox(width: 8),
              Text('Model Training'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will train a machine learning model to automatically classify your products based on sales patterns.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Training Period: $startText to $endText',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Number of clusters: 3',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text(
                '• Training may take a few moments to complete\n'
                '• Model will use the current date range and settings\n'
                '• This will improve category consistency across different time periods',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                // Use the stored bloc reference instead of trying to read from context
                clusteringBloc.add(const RetrainModelEvent());
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Start Training'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClusterSection(int clusterId, String clusterLabel,
      Color clusterColor, List<ProductCluster> products) {
    // Sort products by total sales in descending order within each cluster
    products.sort((a, b) => b.totalSales.compareTo(a.totalSales));

    // Check if we should show all items or just top 10
    final bool showAll = _showAllItems[clusterId] ?? false;
    final displayProducts = showAll ? products : products.take(10).toList();
    final hasMore = products.length > 10;

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
        collapsedBackgroundColor: clusterColor.withAlpha(13), // 0.05 * 255 = 13
        backgroundColor: clusterColor.withAlpha(13), // 0.05 * 255 = 13
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductsDataTable(displayProducts),

                // Show all button when we have more than 10 products
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllItems[clusterId] = !showAll;
                          });
                        },
                        icon: Icon(
                          showAll ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(
                          showAll
                              ? 'Show Less'
                              : 'Show All (${products.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: clusterColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsDataTable(List<ProductCluster> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return FutureBuilder<String>(
          future: _getProductName(product.upc),
          builder: (context, snapshot) {
            final productName = snapshot.hasData ? snapshot.data! : product.upc;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    const Icon(Icons.shopping_cart,
                        size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Sales: ${product.totalSales.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Days: ${product.daysSold}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _buildProductStatRow('Sales Statistics', [
                    ProductStat(
                        'Total',
                        '${product.totalSales.toStringAsFixed(0)}',
                        Icons.shopping_cart_checkout),
                    ProductStat(
                        'Avg Daily',
                        '${product.avgDailySales.toStringAsFixed(1)}',
                        Icons.trending_up),
                    ProductStat(
                        'Frequency',
                        '${product.salesFrequency.toStringAsFixed(2)}',
                        Icons.repeat),
                  ]),
                  const SizedBox(height: 12),
                  _buildProductStatRow('Sales Range', [
                    ProductStat(
                        'Max',
                        '${product.maxDailySales.toStringAsFixed(0)}',
                        Icons.arrow_upward),
                    ProductStat(
                        'Min',
                        '${product.minDailySales.toStringAsFixed(0)}',
                        Icons.arrow_downward),
                    ProductStat(
                        'Std Dev',
                        '${product.stdDailySales.toStringAsFixed(2)}',
                        Icons.show_chart),
                  ]),
                  const SizedBox(height: 12),
                  _buildProductStatRow('Additional Info', [
                    ProductStat('Days Sold', '${product.daysSold}',
                        Icons.calendar_month),
                    ProductStat('Days Since', '${product.daysSinceLastSale}',
                        Icons.access_time),
                    ProductStat(
                        'Tx Count', '${product.txCount}', Icons.receipt_long),
                  ]),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductStatRow(String sectionTitle, List<ProductStat> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stats.map((stat) {
            return Expanded(
              child: Column(
                children: [
                  Icon(stat.icon, size: 18, color: Colors.blue[700]),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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

    // Set selected year based on current state or default to current year
    int yearToUse = currentState.startDate?.year ?? _currentYear;

    // Make sure the selected year exists in the available years list
    if (!_availableYears.contains(yearToUse)) {
      yearToUse =
          _availableYears.isNotEmpty ? _availableYears.last : _currentYear;
    }

    setState(() {
      _selectedYear = yearToUse;
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.filter_alt, size: 24),
                  SizedBox(width: 8),
                  Text('Filter Options'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
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
                    value: _availableYears.contains(_selectedYear)
                        ? _selectedYear
                        : _availableYears.first,
                    items: _availableYears
                        .map((year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Products will be classified into 3 categories',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
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
                    _loadDataForYear(_selectedYear);
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

class ProductStat {
  final String label;
  final String value;
  final IconData icon;

  ProductStat(this.label, this.value, this.icon);
}
