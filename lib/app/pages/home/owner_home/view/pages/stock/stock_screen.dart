import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/add_product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/product_detail.dart';
import 'package:primamobile/repository/product_repository.dart';

class StockScreen extends StatelessWidget {
  final ProductRepository productRepository;

  const StockScreen({super.key, required this.productRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock')),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (stockContext, stockState) {
          if (stockState is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (stockState is StockError) {
            return Center(child: Text(stockState.message));
          } else if (stockState is StockLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: stockState.products.length,
              itemBuilder: (context, index) {
                final product = stockState.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle:
                        Text('UPC: ${product.upc}\nStock: ${product.stock}'),
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
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Edit product logic
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            stockContext
                                .read<StockBloc>()
                                .add(DeleteProduct(product.upc));
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
      floatingActionButton: Builder(
        builder: (innerContext) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                innerContext,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: innerContext.read<StockBloc>(),
                    child: AddProductPage(
                      productRepository: productRepository,
                    ),
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
