import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/app/models/classification/product_classification.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/report/bloc/clustering/clustering_bloc.dart';

class ClusteringScreen extends StatefulWidget {
  const ClusteringScreen({super.key});

  @override
  State<ClusteringScreen> createState() => _ClusteringScreenState();
}

class _ClusteringScreenState extends State<ClusteringScreen> {
  int _selectedYear = DateTime.now().year;
  final int _numberOfClusters = 3;
  final int _currentYear = DateTime.now().year;
  List<int> _availableYears = []; // Years with complete data

  // Control show all items or just top 10
  final Map<int, bool> _showAllItems = {};

  @override
  void initState() {
    super.initState();
    _fetchAvailableYearsAndInitialize();
  }

  // Fetch years with complete data and initialize
  Future<void> _fetchAvailableYearsAndInitialize() async {
    try {
      final classificationRepo =
          context.read<ClusteringBloc>().classificationRepository;
      final years = await classificationRepo.fetchYearsWithCompleteData();
      setState(() {
        if (years.isNotEmpty) {
          _availableYears = years.toSet().toList()..sort();
          _selectedYear = _availableYears.last;
          _loadDataForYear(_selectedYear);
        } else {
          // Fallback to current year
          _availableYears = [_currentYear];
          _selectedYear = _currentYear;
          print('No years with complete data found, using current year');

          // Load data for current
          _loadDataForYear(_currentYear);
        }
      });
    } catch (e) {
      // Fallback
      setState(() {
        _availableYears = [_currentYear];
        _selectedYear = _currentYear;
        print('Error fetching years with complete data: $e');

        // fallback
        _loadDataForYear(_currentYear);
      });
    }
  }

  // method to load data for year
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
              return Text('Yearly Report ${state.startDate!.year}');
            }
            return const Text('Yearly Report');
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Training Classification Model...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This process will take a few moments.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
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
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _showTrainModelConfirmation(context),
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
    if (_showAllItems.length != state.groupedClusters.length) {
      _showAllItems.clear();
      for (var clusterId in state.groupedClusters.keys) {
        _showAllItems[clusterId] = false;
      }
    }
    // Get the trained year
    final int? trainedYear = context.read<ClusteringBloc>().lastTrainedYear;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Clusters list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              // Train Model Button
              ElevatedButton.icon(
                onPressed: () => _showTrainModelConfirmation(context),
                icon: const Icon(Icons.model_training),
                label: const Text('Train Classification Model'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              // Year and Trained information
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text(
                          'Year: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${state.startDate?.year ?? _currentYear}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.model_training,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        const Text(
                          'Trained: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          trainedYear != null
                              ? '$trainedYear'
                              : 'Not Yet Trained',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              const Divider(),
              const SizedBox(height: 8),

              // Clusters content
              state.groupedClusters.isEmpty
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
                            const SizedBox(height: 24),
                            // Add Train Model button if no data is available
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showTrainModelConfirmation(context),
                              icon: const Icon(Icons.model_training),
                              label: const Text('Train Classification Model'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.groupedClusters.length,
                      itemBuilder: (context, index) {
                        // order for cluster display:
                        final Map<String, int> categoryPriority = {
                          "Top Seller": 0,
                          "Standard": 1,
                          "Low Seller": 2,
                        };

                        // sort cluster on category priority
                        final sortedClusterIds = state.groupedClusters.keys
                            .toList()
                          ..sort((a, b) {
                            final labelA = state.clusterLabels[a] ?? "Standard";
                            final labelB = state.clusterLabels[b] ?? "Standard";

                            // Extract base category, remove seasonal
                            final baseA = labelA.contains("Seasonal")
                                ? labelA.substring(9)
                                : labelA;
                            final baseB = labelB.contains("Seasonal")
                                ? labelB.substring(9)
                                : labelB;

                            final priorityA = categoryPriority[baseA] ?? 1;
                            final priorityB = categoryPriority[baseB] ?? 1;

                            return priorityA.compareTo(priorityB);
                          });
                        final clusterId = sortedClusterIds[index];
                        final clusterProducts =
                            state.groupedClusters[clusterId]!;
                        String clusterLabel = state.clusterLabels[clusterId] ??
                            'Cluster $clusterId';

                        // remove seasonal
                        if (clusterLabel.startsWith("Seasonal ")) {
                          clusterLabel = clusterLabel.substring(9);
                        }

                        // Set color based on base category
                        Color clusterColor;
                        if (clusterLabel.contains("Top Seller")) {
                          clusterColor = Colors.green[700]!;
                        } else if (clusterLabel.contains("Low Seller")) {
                          clusterColor = Colors.red[700]!;
                        } else {
                          clusterColor = Colors.blue[700]!; // Standard
                        }

                        Widget? labelIcon;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildClusterSection(
                            clusterId,
                            clusterLabel,
                            clusterColor,
                            clusterProducts,
                            labelIcon: labelIcon,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTrainModelConfirmation(BuildContext context) {
    final clusteringState = context.read<ClusteringBloc>().state;
    final clusteringBloc = context.read<ClusteringBloc>();

    DateTime? startDate;
    int selectedTrainingYear = _selectedYear;

    if (clusteringState is ClusteringLoaded) {
      startDate = clusteringState.startDate;
      if (startDate != null) {
        selectedTrainingYear = startDate.year;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  const Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Select Training Year:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    value: _availableYears.contains(selectedTrainingYear)
                        ? selectedTrainingYear
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
                          selectedTrainingYear = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Training Period: January 1, $selectedTrainingYear to December 31, $selectedTrainingYear',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Number of clusters: 3',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
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
                    final newStartDate = DateTime(selectedTrainingYear, 1, 1);
                    final newEndDate = DateTime(selectedTrainingYear, 12, 31);

                    // Update the selected year in the parent widget
                    setState(() {
                      _selectedYear = selectedTrainingYear;
                    });

                    // Call the LoadClusteringEvent with the new dates
                    clusteringBloc.add(
                      LoadClusteringEvent(
                        startDate: newStartDate,
                        endDate: newEndDate,
                        numberOfClusters: 3,
                      ),
                    );

                    // Add a small delay
                    Future.delayed(const Duration(milliseconds: 500), () {
                      // Start model training
                      clusteringBloc.add(const RetrainModelEvent());
                    });
                  },
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start Training'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildClusterSection(int clusterId, String clusterLabel,
      Color clusterColor, List<ProductClassification> products,
      {Widget? labelIcon}) {
    // Sort products by total sales
    products.sort((a, b) => b.totalSales.compareTo(a.totalSales));

    // show all items or just top 10
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
            if (labelIcon != null) ...[
              const SizedBox(width: 4),
              labelIcon,
            ],
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
        collapsedBackgroundColor: clusterColor.withAlpha(13),
        backgroundColor: clusterColor.withAlpha(13),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductsDataTable(displayProducts),

                // Show all button
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

  Widget _buildProductsDataTable(List<ProductClassification> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        // Check if the product is seasonal
        final bool isSeasonal = product.category.contains('Seasonal');

        // Print debug info
        // print(
        //     'Product ${product.upc} has cluster ${product.cluster} with category: ${product.category}, isSeasonal: $isSeasonal');

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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_cart,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Qty: ${product.totalSales.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Tx: ${product.txCount}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    // Show seasonal indicator
                    if (isSeasonal)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.amber[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Seasonal product',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: Colors.amber[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _buildProductStatRow('Sales Statistics', [
                    ProductStat(
                        'Total Sales',
                        '${product.totalSales.toStringAsFixed(0)}',
                        Icons.shopping_cart_checkout),
                    ProductStat(
                        'Avg Daily',
                        '${product.avgDailySales.toStringAsFixed(1)}',
                        Icons.trending_up),
                    ProductStat('Days Sold', '${product.daysSold}',
                        Icons.calendar_month),
                  ]),
                  const SizedBox(height: 12),
                  _buildProductStatRow('Sales Range', [
                    // ProductStat(
                    //     'Max',
                    //     '${product.maxDailySales.toStringAsFixed(0)}',
                    //     Icons.arrow_upward),
                    ProductStat(
                        'Std Dev',
                        '${product.stdDailySales.toStringAsFixed(2)}',
                        Icons.show_chart),
                    ProductStat(
                        'Tx Count', '${product.txCount}', Icons.receipt_long),
                  ]),
                  // const SizedBox(height: 12),
                  // _buildProductStatRow('Additional Info', [
                  //   ProductStat('Days Since Last Sale',
                  //       '${product.daysSinceLastSale}', Icons.access_time),
                  // ]),
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

    // Set selected year
    int yearToUse = currentState.startDate?.year ?? _currentYear;

    // Make sure the selected year exists
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
