import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primamobile/app/models/product/product.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/barcode_scanner.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/utils/helpers/permission_helper.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields.
  final TextEditingController _upcController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _netPriceController = TextEditingController();
  final TextEditingController _displayPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  // Flags and debouncer for UPC checking.
  bool isScanning = false;
  bool _upcExists = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _upcController.addListener(_onUpcChanged);
  }

  void _onUpcChanged() {
    // Debounce the API call to avoid making too many requests.
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkUpcExists(_upcController.text.trim());
    });
  }

  Future<void> _checkUpcExists(String upc) async {
    if (upc.isEmpty) {
      setState(() {
        _upcExists = false;
      });
      return;
    }

    try {
      // Try fetching the product by UPC.
      final productRepository =
          RepositoryProvider.of<ProductRepository>(context);
      await productRepository.fetchProduct(upc);
      // If the product is found, mark UPC as existing.
      setState(() {
        _upcExists = true;
      });
    } catch (e) {
      // If not found (e.g., a 404 error), mark UPC as not existing.
      setState(() {
        _upcExists = false;
      });
    }
  }

  @override
  void dispose() {
    _upcController.removeListener(_onUpcChanged);
    _debounce?.cancel();
    _upcController.dispose();
    _nameController.dispose();
    _netPriceController.dispose();
    _displayPriceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  /// Returns an InputDecoration with optional error text.
  InputDecoration _buildInputDecoration(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide:
            BorderSide(color: errorText != null ? Colors.red : Colors.grey),
      ),
      errorText: errorText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  /// Scans a barcode and updates the UPC field.
  Future<void> _scanBarcode() async {
    if (isScanning) return;
    isScanning = true;

    if (await CameraPermissionHelper.isGranted) {
      final scannedCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => BarcodeScannerScreen(
            onBarcodeScanned: (code) {
              // Barcode scanned callback if needed.
            },
          ),
        ),
      );

      if (scannedCode != null && scannedCode.isNotEmpty) {
        setState(() {
          _upcController.text = scannedCode.trim();
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

    isScanning = false;
  }

  /// Validates the form and dispatches the add product event.
  void _addProduct() {
    final upc = _upcController.text.trim();
    final name = _nameController.text.trim();
    final netPriceText = _netPriceController.text.trim();
    final displayPriceText = _displayPriceController.text.trim();
    final stockText = _stockController.text.trim();
    final category = _categoryController.text.trim();
    final brand = _brandController.text.trim();

    // Optionally update controllers to reflect trimmed text.
    _upcController.text = upc;
    _nameController.text = name;
    _netPriceController.text = netPriceText;
    _displayPriceController.text = displayPriceText;
    _stockController.text = stockText;
    _categoryController.text = category;
    _brandController.text = brand;

    if (_formKey.currentState?.validate() ?? false) {
      final product = Product(
        upc: upc,
        name: name,
        netPrice: double.parse(netPriceText),
        displayPrice: double.parse(displayPriceText),
        stock: int.parse(stockText),
        category: category,
        brand: brand,
      );

      context.read<StockBloc>().add(AddProduct(product));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context);
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
            FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
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
                            decoration: _buildInputDecoration(
                              'UPC',
                              errorText:
                                  _upcExists ? 'UPC already exists.' : null,
                            ),
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return 'UPC is required.';
                              }
                              if (_upcExists) {
                                return 'UPC already exists.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _scanBarcode,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Scan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Product Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Product Name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Net Price Field
                    TextFormField(
                      controller: _netPriceController,
                      decoration: _buildInputDecoration('Net Price'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Net price is required.';
                        }
                        if (double.tryParse(trimmed) == null) {
                          return 'Please enter a valid number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Display Price Field
                    TextFormField(
                      controller: _displayPriceController,
                      decoration: _buildInputDecoration('Display Price'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Display price is required.';
                        }
                        if (double.tryParse(trimmed) == null) {
                          return 'Please enter a valid number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Stock Field
                    TextFormField(
                      controller: _stockController,
                      decoration: _buildInputDecoration('Stock'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Stock is required.';
                        }
                        if (int.tryParse(trimmed) == null) {
                          return 'Please enter a valid integer.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Category Field
                    TextFormField(
                      controller: _categoryController,
                      decoration: _buildInputDecoration('Category'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Brand Field
                    TextFormField(
                      controller: _brandController,
                      decoration: _buildInputDecoration('Brand'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Brand is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
