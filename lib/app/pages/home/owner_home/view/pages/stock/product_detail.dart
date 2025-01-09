import 'package:flutter/material.dart';
import 'package:primamobile/app/models/product/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UPC: ${product.upc}', style: const TextStyle(fontSize: 16)),
            Text('Stock: ${product.stock}',
                style: const TextStyle(fontSize: 16)),
            Text('Price: \$${product.displayPrice}',
                style: const TextStyle(fontSize: 16)),
            Text('Category: \$${product.category}',
                style: const TextStyle(fontSize: 16)),
            Text('Brand: \$${product.brand}',
                style: const TextStyle(fontSize: 16)),
            // Add more product details as needed
          ],
        ),
      ),
    );
  }
}
