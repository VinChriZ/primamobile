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
    _netPriceController =
        TextEditingController(text: widget.product.netPrice.toString());
    _displayPriceController =
        TextEditingController(text: widget.product.displayPrice.toString());
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
      // Build the partial-update map with trimmed input.
      final updateFields = <String, dynamic>{
        'name': _nameController.text.trim(),
        'net_price': double.tryParse(_netPriceController.text.trim()),
        'display_price': double.tryParse(_displayPriceController.text.trim()),
        'stock': int.tryParse(_stockController.text.trim()),
        'category': _categoryController.text.trim(),
        'brand': _brandController.text.trim(),
        'active': true
      };

      // Remove null values to prevent sending them.
      updateFields.removeWhere((key, value) => value == null);

      // Dispatch the UpdateProduct event to the bloc.
      context
          .read<StockBloc>()
          .add(UpdateProduct(widget.product.upc, updateFields));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('Name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  // Net Price Field
                  TextFormField(
                    controller: _netPriceController,
                    decoration: _buildInputDecoration('Net Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return null; // Optional field
                      final parsed = double.tryParse(trimmed);
                      if (parsed == null || parsed <= 0) {
                        return 'Net Price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Display Price Field
                  TextFormField(
                    controller: _displayPriceController,
                    decoration: _buildInputDecoration('Display Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return null; // Optional field
                      final parsed = double.tryParse(trimmed);
                      if (parsed == null || parsed <= 0) {
                        return 'Display Price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Stock Field
                  TextFormField(
                    controller: _stockController,
                    decoration: _buildInputDecoration('Stock'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return null; // Optional field
                      final parsed = int.tryParse(trimmed);
                      if (parsed == null || parsed < 0) {
                        return 'Stock must be 0 or more';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Category Field
                  TextFormField(
                    controller: _categoryController,
                    decoration: _buildInputDecoration('Category'),
                    // Add validator here if needed.
                  ),
                  const SizedBox(height: 16),
                  // Brand Field
                  TextFormField(
                    controller: _brandController,
                    decoration: _buildInputDecoration('Brand'),
                    // Add validator here if needed.
                  ),
                  const SizedBox(height: 24),
                  // Update Button
                  ElevatedButton(
                    onPressed: _updateProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Update Product',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
