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

  /// Returns the formatted value with thousands separators.
  /// If the value is 0, it now returns "0" with the optional prefix.
  String formatTodayValue(dynamic value, {String prefix = ''}) {
    final NumberFormat formatter = NumberFormat.decimalPattern('id_ID');

    if (value == 0) {
      return '${prefix}0';
    } else if (value is double) {
      // Format the double value with thousands separator
      return '$prefix${formatter.format(value)}';
    } else {
      // Format the integer value with thousands separator
      return '$prefix${formatter.format(value)}';
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
              "➤ ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
                fontSize: 14,
              ),
            ),
          ],
          Container(
            width: 100,
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
        toolbarHeight: 100,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 60),
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Welcome, ${Globals.userSession.user.username}!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
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
                    ],
                  ),
                ),
              ),
            );
          } else if (state is HomeLoaded) {
            // If role_id is not 1 or 2, only show the low stock products card
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
                        title: 'Low Stock Products',
                        titleIcon: Icons.warning,
                        color: Colors.white,
                        child: () {
                          // Filter only active products
                          final activeLowStockProducts = dashboard
                              .lowStockProducts
                              .where((product) => product.active == true)
                              .toList();

                          return activeLowStockProducts.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'No active products with low stock.',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: activeLowStockProducts.length,
                                  separatorBuilder: (context, index) => Divider(
                                    color: Colors.red.shade100,
                                  ),
                                  itemBuilder: (context, index) {
                                    final product =
                                        activeLowStockProducts[index];
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
                                );
                        }(),
                      ),

                      // Only show these cards for admin or owner (role_id 1 or 2)
                      if (Globals.userSession.user.roleId == 1 ||
                          Globals.userSession.user.roleId == 2) ...[
                        // Sales Card
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
                        // Items Sold Card
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
                        // Card for Profit
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
                        // Card for Total Stock Price
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
                        const SizedBox(
                          height: 30,
                        )
                      ],
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
