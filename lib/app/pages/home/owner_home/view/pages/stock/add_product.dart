import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primamobile/app/models/product/product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/barcode_scanner.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/utils/helpers/permission_helper.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _upcController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _netPriceController = TextEditingController();
  final TextEditingController _displayPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  bool isScanning = false; // Add this flag

  void _scanBarcode() async {
    if (isScanning) return; // Prevent multiple calls
    isScanning = true;

    if (await CameraPermissionHelper.isGranted) {
      final scannedCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => BarcodeScannerScreen(
            onBarcodeScanned: (code) {
              // No need to pop the scanner, as it's handled internally
            },
          ),
        ),
      );

      if (scannedCode != null && scannedCode.isNotEmpty) {
        setState(() {
          _upcController.text = scannedCode;
        });
      }
    } else if (await CameraPermissionHelper.isDenied) {
      final bool permissionGranted = await CameraPermissionHelper.request();
      if (permissionGranted) {
        _scanBarcode();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan barcodes.'),
          ),
        );
      }
    } else if (await CameraPermissionHelper.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable camera permission from app settings.'),
        ),
      );
      await openAppSettings();
    }

    isScanning = false; // Reset the flag
  }

  void _addProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      final product = Product(
        upc: _upcController.text,
        name: _nameController.text,
        netPrice: double.parse(_netPriceController.text),
        displayPrice: double.parse(_displayPriceController.text),
        stock: int.parse(_stockController.text),
        category: _categoryController.text,
        brand: _brandController.text,
        imageUrl: "https://example.com/image.jpg", // Placeholder
      );

      // Use StockBloc to handle adding the product
      context.read<StockBloc>().add(AddProduct(product));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _upcController,
                      decoration: const InputDecoration(labelText: 'UPC'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'UPC is required.';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _netPriceController,
                decoration: const InputDecoration(labelText: 'Net Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Net Price is required.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayPriceController,
                decoration: const InputDecoration(labelText: 'Display Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Display Price is required.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stock is required.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid integer.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Brand is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
