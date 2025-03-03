import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates and numbers
import 'package:primamobile/app/models/product/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Format prices and dates
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'id_ID');
    final dateFormatter = DateFormat.yMMMMd().add_jm();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name Display
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  product.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Product Details Card
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // UPC
                    Row(
                      children: [
                        const Icon(Icons.confirmation_number),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'UPC: ${product.upc}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Stock
                    Row(
                      children: [
                        const Icon(Icons.storage),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Stock: ${product.stock}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Net Price
                    Row(
                      children: [
                        const Icon(Icons.attach_money),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Net Price: ${currencyFormatter.format(product.netPrice)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Display Price
                    Row(
                      children: [
                        const Icon(Icons.money),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Display Price: ${currencyFormatter.format(product.displayPrice)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Category
                    Row(
                      children: [
                        const Icon(Icons.category),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Category: ${product.category}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Brand
                    Row(
                      children: [
                        const Icon(Icons.branding_watermark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Brand: ${product.brand}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Last Updated
                    if (product.lastUpdated != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.update),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Last Updated: ${dateFormatter.format(product.lastUpdated!)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
