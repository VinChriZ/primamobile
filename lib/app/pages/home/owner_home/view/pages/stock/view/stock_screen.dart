import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/add_product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/edit_product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/product_detail.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    // Trigger the LoadProducts event to refresh data.
    context.read<StockBloc>().add(LoadProducts());
  }

  /// Helper widget to build a row for a given label/value pair.
  Widget _buildAttributeRow(String label, String value) {
    // Extract the base label without the colon
    String baseLabel =
        label.endsWith(':') ? label.substring(0, label.length - 1) : label;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150, // Increased width from 110 to 130
          padding: const EdgeInsets.only(right: 5), // Add right padding
          child: Text(
            baseLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16, // Increased from 15
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 5), // Space before colon
        const Text(
          ":",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16, // Increased from 15
          ),
        ),
        const SizedBox(width: 10), // Space after colon
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16), // Increased from 15
          ),
        ),
      ],
    );
  }

  /// Helper widget to build a card with consistent styling across the app.
  Widget _buildCard({
    required Widget child,
    Color? color,
    String? title,
    IconData? titleIcon,
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
                        size: 20,
                        color: Colors.blue[800],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
      appBar: AppBar(title: const Text('Stock')),
      body: Column(
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
                hintText: 'Search product by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4.0),

          // FILTERS + SORT IN A ROW
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                            contentPadding:
                                EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0),
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
                              child: Text("All Categories"),
                            ),
                            ...state.categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(width: 16.0),

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
                            contentPadding:
                                EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0),
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
                              child: Text("All Brands"),
                            ),
                            ...state.brands.map((brand) {
                              return DropdownMenuItem(
                                value: brand,
                                child: Text(brand),
                              );
                            }),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(width: 16.0),

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
                            contentPadding:
                                EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0),
                          ),
                          value: state.sortOption ?? 'Last Updated',
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<StockBloc>()
                                  .add(SortProducts(value));
                            }
                          },
                          items: [
                            'Lowest Stock',
                            'Highest Stock',
                            'Last Updated',
                          ].map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
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
          ),

          // PRODUCT LIST WITH REFRESH INDICATOR
          Expanded(
            child: BlocBuilder<StockBloc, StockState>(
              builder: (context, stockState) {
                return RefreshIndicator(
                  onRefresh: () => _refreshProducts(context),
                  child: stockState is StockLoading
                      ? const Center(child: CircularProgressIndicator())
                      : stockState is StockError
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Center(child: Text(stockState.message)),
                              ],
                            )
                          : stockState is StockLoaded
                              ? stockState.displayedProducts.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        Center(
                                            child: Text('No products found.')),
                                      ],
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount:
                                          stockState.displayedProducts.length,
                                      itemBuilder: (context, index) {
                                        final product =
                                            stockState.displayedProducts[index];
                                        return _buildCard(
                                          title: product.name,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              InkWell(
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
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildAttributeRow(
                                                        'Stock',
                                                        product.stock
                                                            .toString()),
                                                    const SizedBox(height: 4.0),
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
                                              ),
                                              const SizedBox(height: 16.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                                10.0), // Reduced padding
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                BlocProvider
                                                                    .value(
                                                              value: context.read<
                                                                  StockBloc>(),
                                                              child: EditProductPage(
                                                                  product:
                                                                      product),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                        'Edit',
                                                        style: TextStyle(
                                                          fontSize:
                                                              14, // Reduced from 16
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                                10.0), // Reduced padding
                                                      ),
                                                      onPressed: () {
                                                        final stockBloc =
                                                            context.read<
                                                                StockBloc>();
                                                        showDialog(
                                                          context: context,
                                                          builder:
                                                              (dialogContext) =>
                                                                  AlertDialog(
                                                            title: const Text(
                                                                'Delete Product'),
                                                            content: const Text(
                                                                'Are you sure you want to delete this product?'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop(),
                                                                child: const Text(
                                                                    'Cancel'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  stockBloc.add(
                                                                      DeleteProduct(
                                                                          product
                                                                              .upc));
                                                                  Navigator.of(
                                                                          dialogContext)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Delete',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          fontSize:
                                                              14, // Reduced from 16
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                              : ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    Center(child: Text('No products found.')),
                                  ],
                                ),
                );
              },
            ),
          ),
        ],
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
