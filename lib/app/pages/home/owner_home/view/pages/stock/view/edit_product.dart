// edit_product_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/product/product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _netPriceController;
  late TextEditingController _displayPriceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _netPriceController = TextEditingController(
      text: widget.product.netPrice.toString(),
    );
    _displayPriceController = TextEditingController(
      text: widget.product.displayPrice.toString(),
    );
    _stockController =
        TextEditingController(text: widget.product.stock.toString());
    _categoryController = TextEditingController(text: widget.product.category);
    _brandController = TextEditingController(text: widget.product.brand);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _netPriceController.dispose();
    _displayPriceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  void _updateProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      // Build the partial-update map using toPartialJson()
      final updateFields = <String, dynamic>{
        'name': _nameController.text.trim(),
        'net_price': double.tryParse(_netPriceController.text.trim()),
        'display_price': double.tryParse(_displayPriceController.text.trim()),
        'stock': int.tryParse(_stockController.text.trim()),
        'category': _categoryController.text.trim(),
        'brand': _brandController.text.trim(),
      };

      // Optionally, remove null values to prevent sending them
      updateFields.removeWhere((key, value) => value == null);

      // Dispatch the UpdateProduct event to the bloc
      context
          .read<StockBloc>()
          .add(UpdateProduct(widget.product.upc, updateFields));

      // Optionally show a success message before popping
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );

      // Go back to the previous screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ---- Name ----
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Name is required' : null,
            ),

            // ---- Net Price ----
            TextFormField(
              controller: _netPriceController,
              decoration: const InputDecoration(labelText: 'Net Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return null; // optional
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Net Price must be greater than 0';
                }
                return null;
              },
            ),

            // ---- Display Price ----
            TextFormField(
              controller: _displayPriceController,
              decoration: const InputDecoration(labelText: 'Display Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return null; // optional
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Display Price must be greater than 0';
                }
                return null;
              },
            ),

            // ---- Stock ----
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return null; // optional
                final parsed = int.tryParse(value);
                if (parsed == null || parsed < 0) {
                  return 'Stock must be 0 or more';
                }
                return null;
              },
            ),

            // ---- Category ----
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),

            // ---- Brand ----
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),

            const SizedBox(height: 20),

            // ---- Update Button ----
            ElevatedButton(
              onPressed: _updateProduct,
              child: const Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}
