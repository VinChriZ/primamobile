import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primamobile/app/models/product/product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/barcode_scanner.dart';
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
  final TextEditingController _imageUrlController = TextEditingController();

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
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : null,
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
      appBar: AppBar(
        title: const Text('Add Product'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // UPC Field with Scan Button
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _upcController,
                            decoration: const InputDecoration(
                              labelText: 'UPC',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.confirmation_number),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'UPC is required.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _scanBarcode,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 20.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Product name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Net Price Field
                    TextFormField(
                      controller: _netPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Net Price',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Net price is required.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Display Price Field
                    TextFormField(
                      controller: _displayPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Display Price',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Display price is required.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Stock Field
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.storage),
                      ),
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
                    const SizedBox(height: 20),

                    // Category Field
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Brand Field
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.branding_watermark),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Brand is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Image URL Field (Optional)
                    // TextFormField(
                    //   controller: _imageUrlController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Image URL (Optional)',
                    //     border: OutlineInputBorder(),
                    //     prefixIcon: Icon(Icons.image),
                    //   ),
                    //   keyboardType: TextInputType.url,
                    //   validator: (value) {
                    //     if (value != null && value.isNotEmpty) {
                    //       final uri = Uri.tryParse(value);
                    //       if (uri == null || !uri.isAbsolute) {
                    //         return 'Please enter a valid URL.';
                    //       }
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 30),

                    // Add Product Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Add Product',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
