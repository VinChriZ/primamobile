import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/home/bloc/home_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/barcode_scanner.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/product_detail.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/utils/globals.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Returns "-" if the value is 0; otherwise, returns a string formatted
  /// with an optional prefix.
  String formatTodayValue(dynamic value, {String prefix = ''}) {
    if (value == 0) {
      return '-';
    } else {
      if (value is double) {
        return '$prefix${value.toStringAsFixed(2)}';
      } else {
        return '$prefix$value';
      }
    }
  }

  Widget buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.lightBlue.shade100,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 80,
        // Wrap the flexibleSpace with SafeArea to avoid overlapping the notification bar.
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Welcome ${Globals.userSession.user.username}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeError) {
            return Center(child: Text(state.message));
          } else if (state is HomeLoaded) {
            // If role_id is not 1 or 2, hide all cards.
            if (Globals.userSession.user.roleId != 1 &&
                Globals.userSession.user.roleId != 2) {
              return const Center(child: Text("No content available."));
            }
            final dashboard = state.dashboardData;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeStarted());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Card for Low Stock Products
                      buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Low Stock Products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            dashboard.lowStockProducts.isEmpty
                                ? const Text('No products with low stock.')
                                : Column(
                                    children: dashboard.lowStockProducts
                                        .map(
                                          (product) => ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(product.name),
                                            subtitle:
                                                Text('Stock: ${product.stock}'),
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ],
                        ),
                      ),
                      // Row for Transactions and Items Sold
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(right: 8, bottom: 16),
                              child: Card(
                                color: Colors.lightBlue.shade100,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Sales',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      buildStatRow(
                                        'Today',
                                        formatTodayValue(
                                            dashboard.transactionsToday),
                                      ),
                                      buildStatRow(
                                        'Month',
                                        dashboard.transactionsMonth.toString(),
                                      ),
                                      buildStatRow(
                                        'Year',
                                        dashboard.transactionsYear.toString(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 8, bottom: 16),
                              child: Card(
                                color: Colors.lightBlue.shade100,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Items Sold',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      buildStatRow(
                                        'Today',
                                        formatTodayValue(
                                            dashboard.itemsSoldToday),
                                      ),
                                      buildStatRow(
                                        'Month',
                                        dashboard.itemsSoldMonth.toString(),
                                      ),
                                      buildStatRow(
                                        'Year',
                                        dashboard.itemsSoldYear.toString(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Card for Profit
                      buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildStatRow(
                              'Today',
                              formatTodayValue(dashboard.profitToday,
                                  prefix: 'Rp. '),
                            ),
                            buildStatRow(
                              'Month',
                              'Rp. ${dashboard.profitMonth.toStringAsFixed(2)}',
                            ),
                            buildStatRow(
                              'Year',
                              'Rp. ${dashboard.profitYear.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                      // Card for Total Stock Price
                      buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Stock Price',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildStatRow(
                              'Total',
                              'Rp. ${dashboard.totalStockPrice.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: Text('Unexpected state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          // Navigate to the barcode scanner screen
          final String? upc = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeScannerScreen(
                onBarcodeScanned: (scannedCode) {},
              ),
            ),
          );
          if (upc != null) {
            // Fetch the product details using the scanned UPC.
            final productRepository =
                RepositoryProvider.of<ProductRepository>(context);
            try {
              final product = await productRepository.fetchProduct(upc);
              // Navigate to the product detail page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            } catch (e) {
              // Handle error (e.g., product not found)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to fetch product details."),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
