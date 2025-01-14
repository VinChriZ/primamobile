import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          // Search Field
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
          // Horizontally Scrollable Filters and Sort Options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Category Dropdown
                BlocBuilder<StockBloc, StockState>(
                  builder: (context, state) {
                    if (state is StockLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is StockLoaded) {
                      return DropdownButton<String>(
                        isExpanded: false,
                        hint: const Text('Select Category'),
                        value: state.selectedCategory,
                        onChanged: (value) {
                          context.read<StockBloc>().add(
                                FilterProducts(category: value),
                              );
                        },
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...state.categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 16.0),
                // Brand Dropdown
                BlocBuilder<StockBloc, StockState>(
                  builder: (context, state) {
                    if (state is StockLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is StockLoaded) {
                      return DropdownButton<String>(
                        isExpanded: false,
                        hint: const Text('Select Brand'),
                        value: state.selectedBrand,
                        onChanged: (value) {
                          context.read<StockBloc>().add(
                                FilterProducts(brand: value),
                              );
                        },
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Brands'),
                          ),
                          ...state.brands.map((brand) {
                            return DropdownMenuItem(
                              value: brand,
                              child: Text(brand),
                            );
                          }).toList(),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 16.0),
                // Sort Dropdown
                BlocBuilder<StockBloc, StockState>(
                  builder: (context, state) {
                    if (state is StockLoaded) {
                      return DropdownButton<String>(
                        isExpanded: false,
                        value: state.sortOption ?? 'Last Updated',
                        onChanged: (value) {
                          if (value != null) {
                            context.read<StockBloc>().add(SortProducts(value));
                          }
                        },
                        items: ['Lowest Stock', 'Highest Stock', 'Last Updated']
                            .map((option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 16.0),
                // Optional: Add more filters or buttons here
              ],
            ),
          ),
          // Product List
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
                    padding: const EdgeInsets.all(8.0),
                    itemCount: stockState.displayedProducts.length,
                    itemBuilder: (context, index) {
                      final product = stockState.displayedProducts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                              'UPC: ${product.upc}\nStock: ${product.stock}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(product: product),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<StockBloc>(),
                                        child:
                                            EditProductPage(product: product),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Confirm deletion with the user before deleting
                                  final stockBloc = context.read<StockBloc>();

                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete Product'),
                                      content: const Text(
                                          'Are you sure you want to delete this product?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            stockBloc.add(
                                                DeleteProduct(product.upc));
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
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
