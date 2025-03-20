import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/home/bloc/home_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/barcode_scanner.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/product_detail.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/utils/globals.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Returns "-" if the value is 0; otherwise, returns a string formatted
  /// with an optional prefix and thousands separators.
  String formatTodayValue(dynamic value, {String prefix = ''}) {
    if (value == 0) {
      return '-';
    } else {
      // Create a NumberFormat instance for Indonesian format (uses . as thousand separator)
      final NumberFormat formatter = NumberFormat.decimalPattern('id_ID');

      if (value is double) {
        // Format the double value with thousands separator
        return '$prefix${formatter.format(value)}';
      } else {
        // Format the integer value with thousands separator
        return '$prefix${formatter.format(value)}';
      }
    }
  }

  Widget buildStatRow(String label, String value,
      {IconData? icon, bool useBullet = false}) {
    // Extract the base label without the colon
    String baseLabel =
        label.endsWith(':') ? label.substring(0, label.length - 1) : label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.blue[700]),
            const SizedBox(width: 8),
          ] else if (useBullet) ...[
            Text(
              "➤ ", // Right-pointing arrow bullet
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
                fontSize: 14,
              ),
            ),
          ],
          Container(
            width: 70,
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              baseLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            ":",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required Widget child,
    Color? color,
    String? title,
    IconData? titleIcon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: color ?? Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    if (titleIcon != null) ...[
                      Icon(
                        titleIcon,
                        size: 20,
                        color: Colors.blue[800],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.blue.shade300, thickness: 1),
                const SizedBox(height: 8),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[800]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Welcome, ${Globals.userSession.user.username}!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                      // Card for Low Stock Products - Changed background to white
                      buildCard(
                        title: 'Low Stock Products',
                        titleIcon: Icons.warning,
                        color: Colors.white, // Changed from red[50] to white
                        child: dashboard.lowStockProducts.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'No products with low stock.',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dashboard.lowStockProducts.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.red.shade100,
                                ),
                                itemBuilder: (context, index) {
                                  final product =
                                      dashboard.lowStockProducts[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.inventory,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            product.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Stock: ${product.stock}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      // Sales Card (Now full-width and vertical)
                      buildCard(
                        title: 'Total Sales',
                        titleIcon: Icons.receipt,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildStatRow(
                              'Today',
                              formatTodayValue(dashboard.transactionsToday),
                              useBullet: true,
                            ),
                            buildStatRow(
                              'Month',
                              dashboard.transactionsMonth.toString(),
                              useBullet: true,
                            ),
                            buildStatRow(
                              'Year',
                              dashboard.transactionsYear.toString(),
                              useBullet: true,
                            ),
                          ],
                        ),
                      ),
                      // Items Sold Card (Now full-width and vertical)
                      buildCard(
                        title: 'Total Items Sold',
                        titleIcon: Icons.shopping_cart,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildStatRow(
                              'Today',
                              formatTodayValue(dashboard.itemsSoldToday),
                              useBullet: true,
                            ),
                            buildStatRow(
                              'Month',
                              dashboard.itemsSoldMonth.toString(),
                              useBullet: true,
                            ),
                            buildStatRow(
                              'Year',
                              dashboard.itemsSoldYear.toString(),
                              useBullet: true,
                            ),
                          ],
                        ),
                      ),
                      // Card for Profit with formatted values
                      buildCard(
                        title: 'Total Profit',
                        titleIcon: Icons.trending_up,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildStatRow(
                              'Today',
                              formatTodayValue(dashboard.profitToday,
                                  prefix: 'Rp. '),
                              useBullet: true,
                            ),
                            buildStatRow(
                              'Month',
                              'Rp. ${formatTodayValue(dashboard.profitMonth)}',
                              useBullet: true,
                            ),
                            buildStatRow(
                              'Year',
                              'Rp. ${formatTodayValue(dashboard.profitYear)}',
                              useBullet: true,
                            ),
                          ],
                        ),
                      ),
                      // Card for Total Stock Price with centered value
                      buildCard(
                        title: 'Total Stock Price',
                        titleIcon: Icons.inventory_2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              'Rp. ${formatTodayValue(dashboard.totalStockPrice)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
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
          return const Center(child: Text('Unexpected state'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scan"),
        backgroundColor: Colors.blue[700],
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
