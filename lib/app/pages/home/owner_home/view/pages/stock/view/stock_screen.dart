import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/add_product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/edit_product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/product_detail.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

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
                  // If search query is empty, reset search
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

          // FILTERS + SORT IN A ROW
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      return DropdownButton<String>(
                        // If no category is selected, default to "All Categories"
                        value: state.selectedCategory ?? "All Categories",
                        hint: const Text('Select Category'),
                        onChanged: (value) {
                          // Preserve existing brand when changing category
                          final currentBrand =
                              state.selectedBrand ?? "All Brands";
                          // Send the new filter event with the chosen category
                          context.read<StockBloc>().add(
                                FilterProducts(
                                  category: value!, // value is non-null here
                                  brand: currentBrand,
                                ),
                              );
                        },
                        items: [
                          // Sentinel item for all categories
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
                      return DropdownButton<String>(
                        // If no brand is selected, default to "All Brands"
                        value: state.selectedBrand ?? "All Brands",
                        hint: const Text('Select Brand'),
                        onChanged: (value) {
                          // Preserve existing category when changing brand
                          final currentCategory =
                              state.selectedCategory ?? "All Categories";
                          context.read<StockBloc>().add(
                                FilterProducts(
                                  category: currentCategory,
                                  brand: value!, // value is non-null here
                                ),
                              );
                        },
                        items: [
                          // Sentinel item for all brands
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
                      return DropdownButton<String>(
                        value: state.sortOption ?? 'Last Updated',
                        onChanged: (value) {
                          if (value != null) {
                            context.read<StockBloc>().add(SortProducts(value));
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
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // PRODUCT LIST
          Expanded(
            child: BlocBuilder<StockBloc, StockState>(
              builder: (context, stockState) {
                if (stockState is StockLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (stockState is StockError) {
                  return Center(child: Text(stockState.message));
                } else if (stockState is StockLoaded) {
                  if (stockState.displayedProducts.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: stockState.displayedProducts.length,
                    itemBuilder: (context, index) {
                      final product = stockState.displayedProducts[index];
                      return Card(
                        color: Colors.lightBlue[100],
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        // Increased card padding
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Custom header using InkWell for tap functionality
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailPage(product: product),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 8.0), // space after title
                                    Text('Stock: ${product.stock}'),
                                    Text(
                                      'Last Updated: ${product.lastUpdated != null ? DateFormat('yyyy-MM-dd').format(product.lastUpdated!) : 'N/A'}',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              // Row with two Expanded buttons for Edit and Delete
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          // Increased button height
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  BlocProvider.value(
                                                value:
                                                    context.read<StockBloc>(),
                                                child: EditProductPage(
                                                    product: product),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                        ),
                                        onPressed: () {
                                          final stockBloc =
                                              context.read<StockBloc>();
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) =>
                                                AlertDialog(
                                              title:
                                                  const Text('Delete Product'),
                                              content: const Text(
                                                'Are you sure you want to delete this product?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                          dialogContext)
                                                      .pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    stockBloc.add(
                                                      DeleteProduct(
                                                          product.upc),
                                                    );
                                                    Navigator.of(dialogContext)
                                                        .pop();
                                                  },
                                                  child: const Text(
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
                                              fontWeight: FontWeight.bold),
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
                  );
                }
                // Fallback if state is not StockLoaded
                return const Center(child: Text('No products found.'));
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
