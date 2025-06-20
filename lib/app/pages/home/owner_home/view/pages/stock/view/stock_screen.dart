import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/add_product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/edit_product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/product_detail.dart';
import 'package:primamobile/utils/globals.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    // Trigger the LoadProducts event to refresh data.
    context.read<StockBloc>().add(LoadProducts());
  }

  /// build row for a label
  Widget _buildAttributeRow(String label, String value) {
    String baseLabel =
        label.endsWith(':') ? label.substring(0, label.length - 1) : label;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          padding: const EdgeInsets.only(right: 5),
          child: Text(
            baseLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          ":",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// widget to build a card
  Widget _buildCard({
    required Widget child,
    Color? color,
    String? title,
    IconData? titleIcon,
    bool titleWrapping = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                        size: 18,
                        color: Colors.blue[800],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: titleWrapping,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.blue.shade300, thickness: 1),
                const SizedBox(height: 6),
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
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH FIELD
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<StockBloc>().add(const SearchProducts(''));
                  } else {
                    context.read<StockBloc>().add(SearchProducts(value));
                  }
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search product by name',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),

            // FILTERS + SORT IN A ROW
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
              child: Row(
                children: [
                  // CATEGORY DROPDOWN
                  BlocBuilder<StockBloc, StockState>(
                    builder: (context, state) {
                      if (state is StockLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is StockLoaded) {
                        return SizedBox(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Select Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                            ),
                            value: state.selectedCategory ?? "All Categories",
                            onChanged: (value) {
                              final currentBrand =
                                  state.selectedBrand ?? "All Brands";
                              context.read<StockBloc>().add(
                                    FilterProducts(
                                      category: value!,
                                      brand: currentBrand,
                                    ),
                                  );
                            },
                            items: [
                              const DropdownMenuItem(
                                value: "All Categories",
                                child: Text(
                                  "All Categories",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              ...state.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category,
                                      style: const TextStyle(fontSize: 13)),
                                );
                              }),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(width: 8.0),

                  // BRAND DROPDOWN
                  BlocBuilder<StockBloc, StockState>(
                    builder: (context, state) {
                      if (state is StockLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is StockLoaded) {
                        return SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Select Brand',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                            ),
                            value: state.selectedBrand ?? "All Brands",
                            onChanged: (value) {
                              final currentCategory =
                                  state.selectedCategory ?? "All Categories";
                              context.read<StockBloc>().add(
                                    FilterProducts(
                                      category: currentCategory,
                                      brand: value!,
                                    ),
                                  );
                            },
                            items: [
                              const DropdownMenuItem(
                                value: "All Brands",
                                child: Text("All Brands",
                                    style: TextStyle(fontSize: 13)),
                              ),
                              ...state.brands.map((brand) {
                                return DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand,
                                      style: const TextStyle(fontSize: 13)),
                                );
                              }),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(width: 8.0),

                  // SORT DROPDOWN
                  BlocBuilder<StockBloc, StockState>(
                    builder: (context, state) {
                      if (state is StockLoaded) {
                        return SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Sort Option',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                            ),                            value: state.sortOption ?? 'Alphabetical',
                            onChanged: (value) {
                              if (value != null) {
                                context
                                    .read<StockBloc>()
                                    .add(SortProducts(value));
                              }
                            },
                            items: [
                              'Alphabetical',
                              'Lowest Stock',
                              'Highest Stock',
                              'Last Updated',
                            ].map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option,
                                    style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ), // PRODUCT LIST
            Expanded(
              child: BlocListener<StockBloc, StockState>(
                listener: (context, state) {
                  if (state is StockError &&
                      state.message.contains('Cannot delete product')) {
                    // Show dialog for deletion errors
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Cannot Delete Product'),
                        content: Text(state.message
                            .replaceFirst('Cannot delete product: ', '')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    // Reload products to clear the error state
                    context.read<StockBloc>().add(LoadProducts());
                  }
                },
                child: BlocBuilder<StockBloc, StockState>(
                  builder: (context, stockState) {
                    return RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: stockState is StockLoading
                          ? const Center(child: CircularProgressIndicator())
                          : stockState is StockError
                              ? SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
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
                                            'Error: ${stockState.message}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : stockState is StockLoaded
                                  ? stockState.displayedProducts.isEmpty
                                      ? ListView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          children: const [
                                            Center(
                                                child:
                                                    Text('No products found.')),
                                          ],
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: stockState
                                              .displayedProducts.length,
                                          itemBuilder: (context, index) {
                                            final product = stockState
                                                .displayedProducts[index];
                                            return InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailPage(
                                                            product: product),
                                                  ),
                                                );
                                              },
                                              child: _buildCard(
                                                title: product.name,
                                                titleWrapping: true,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildAttributeRow(
                                                            'Stock',
                                                            product.stock
                                                                .toString()),
                                                        const SizedBox(
                                                            height: 4.0),
                                                        _buildAttributeRow(
                                                          'Last Updated',
                                                          product.lastUpdated !=
                                                                  null
                                                              ? DateFormat(
                                                                      'yyyy-MM-dd')
                                                                  .format(product
                                                                      .lastUpdated!)
                                                              : 'N/A',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height:
                                                            16.0), // Only show Edit and Delete buttons if user role is 1 or 2
                                                    if (Globals.userSession.user
                                                                .roleId ==
                                                            1 ||
                                                        Globals.userSession.user
                                                                .roleId ==
                                                            2)
                                                      Row(
                                                        children: [
                                                          // Edit button
                                                          Expanded(
                                                            child: SizedBox(
                                                              height: 34,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors.blue[
                                                                          600],
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (_) =>
                                                                          BlocProvider
                                                                              .value(
                                                                        value: context
                                                                            .read<StockBloc>(),
                                                                        child: EditProductPage(
                                                                            product:
                                                                                product),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Edit',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8.0),
                                                          // Delete button
                                                          Expanded(
                                                            child: SizedBox(
                                                              height: 34,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors.red[
                                                                          400],
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  final stockBloc =
                                                                      context.read<
                                                                          StockBloc>();

                                                                  // Show loading dialog while checking
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        false,
                                                                    builder:
                                                                        (context) =>
                                                                            const AlertDialog(
                                                                      content:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          CircularProgressIndicator(),
                                                                          SizedBox(
                                                                              height: 16),
                                                                          Text(
                                                                              'Checking...'),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );

                                                                  try {
                                                                    // Check for transactions and reports
                                                                    final transactionRepo =
                                                                        stockBloc
                                                                            .getTransactionDetailRepository;
                                                                    final reportRepo =
                                                                        stockBloc
                                                                            .getReportDetailRepository;

                                                                    final hasTransactions =
                                                                        await transactionRepo
                                                                            .checkUpcExists(product.upc);
                                                                    final hasReports =
                                                                        await reportRepo
                                                                            .checkUpcExists(product.upc);

                                                                    // Close loading dialog
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    if (hasTransactions ||
                                                                        hasReports) {
                                                                      // Show warning dialog
                                                                      String
                                                                          warningMessage =
                                                                          'Cannot delete product, product found in:\n';
                                                                      if (hasTransactions) {
                                                                        warningMessage +=
                                                                            '• Transactions\n';
                                                                      }
                                                                      if (hasReports) {
                                                                        warningMessage +=
                                                                            '• Worker Reports\n';
                                                                      }
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (dialogContext) =>
                                                                                AlertDialog(
                                                                          title:
                                                                              const Center(
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Icon(Icons.warning, color: Colors.orange, size: 20),
                                                                                SizedBox(width: 8),
                                                                                Text(
                                                                                  'Cannot Delete',
                                                                                  style: TextStyle(
                                                                                    fontSize: 23,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          content:
                                                                              Text(
                                                                            warningMessage,
                                                                            style:
                                                                                const TextStyle(fontSize: 14),
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.of(dialogContext).pop(),
                                                                              child: const Text('OK'),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      // Show confirmation dialog for deletion
                                                                      final shouldDelete =
                                                                          await showDialog<
                                                                              bool>(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (dialogContext) =>
                                                                                AlertDialog(
                                                                          title:
                                                                              const Text('Delete Product'),
                                                                          content:
                                                                              Text('Are you sure you want to delete "${product.name}"?'),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.of(dialogContext).pop(false),
                                                                              child: const Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () => Navigator.of(dialogContext).pop(true),
                                                                              child: const Text(
                                                                                'Delete',
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );

                                                                      if (shouldDelete ==
                                                                          true) {
                                                                        stockBloc
                                                                            .add(DeleteProduct(product.upc));
                                                                      }
                                                                    }
                                                                  } catch (e) {
                                                                    // Close loading dialog
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();

                                                                    // Show error dialog
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (dialogContext) =>
                                                                              AlertDialog(
                                                                        title: const Text(
                                                                            'Error'),
                                                                        content:
                                                                            Text('Failed to check product associations: $e'),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.of(dialogContext).pop(),
                                                                            child:
                                                                                const Text('OK'),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Delete',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                  : ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        Center(
                                            child: Text('No products found.')),
                                      ],
                                    ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
        backgroundColor: Colors.blue[700],
        onPressed: () {
          final stockBloc = context.read<StockBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: stockBloc,
                child: const AddProductPage(),
              ),
            ),
          );
        },
      ),
    );
  }
}
