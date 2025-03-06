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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                      padding: const EdgeInsets.all(16.0),
                                      itemCount:
                                          stockState.displayedProducts.length,
                                      itemBuilder: (context, index) {
                                        final product =
                                            stockState.displayedProducts[index];
                                        return Card(
                                          color: Colors.lightBlue[100],
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
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
                                                                product:
                                                                    product),
                                                      ),
                                                    );
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        product.name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.0,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 8.0),
                                                      Text(
                                                          'Stock: ${product.stock}'),
                                                      Text(
                                                        'Last Updated: ${product.lastUpdated != null ? DateFormat('yyyy-MM-dd').format(product.lastUpdated!) : 'N/A'}',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.blue,
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        12.0),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    BlocProvider
                                                                        .value(
                                                                  value: context
                                                                      .read<
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
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        12.0),
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
                                                                        Navigator.of(dialogContext)
                                                                            .pop(),
                                                                    child: const Text(
                                                                        'Cancel'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      stockBloc.add(
                                                                          DeleteProduct(
                                                                              product.upc));
                                                                      Navigator.of(
                                                                              dialogContext)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'Delete',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
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
                                    Center(child: Text('No products found.')),
                                  ],
                                ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
