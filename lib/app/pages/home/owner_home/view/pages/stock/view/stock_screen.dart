import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/add_product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/product_detail.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Capture the parent context's StockBloc first:
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
