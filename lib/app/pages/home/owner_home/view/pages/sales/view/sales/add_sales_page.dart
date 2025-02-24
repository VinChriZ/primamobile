import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart';

/// A model representing a product added to the sales transaction.
class SalesProductItem {
  final Product product;
  final int quantity;
  final double agreedPrice;

  SalesProductItem({
    required this.product,
    required this.quantity,
    required this.agreedPrice,
  });

  @override
  String toString() {
    return 'SalesProductItem(product: ${product.name}, quantity: $quantity, agreedPrice: $agreedPrice)';
  }
}

/// Page to add a new sales transaction.
class AddSalesPage extends StatefulWidget {
  const AddSalesPage({super.key});

  @override
  State<AddSalesPage> createState() => _AddSalesPageState();
}

class _AddSalesPageState extends State<AddSalesPage> {
  final _formKey = GlobalKey<FormState>();

  // Transaction fields
  DateTime _transactionDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  // List to store products added to the sale.
  final List<SalesProductItem> _salesItems = [];

  // Get running total of agreed price.
  double get _totalAgreedPrice {
    return _salesItems.fold(
      0.0,
      (sum, item) => sum + (item.agreedPrice * item.quantity),
    );
  }

  late final TransactionRepository _transactionRepository;
  late final TransactionDetailRepository _transactionDetailRepository;
  late final ProductRepository _productRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get repositories from the context.
    _transactionRepository =
        RepositoryProvider.of<TransactionRepository>(context);
    _transactionDetailRepository =
        RepositoryProvider.of<TransactionDetailRepository>(context);
    _productRepository = RepositoryProvider.of<ProductRepository>(context);
  }

  /// Called when the user wants to add a product.
  void _openAddProductOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan Barcode'),
                onTap: () async {
                  Navigator.pop(context);
                  await _scanAndAddProduct();
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Product'),
                onTap: () async {
                  Navigator.pop(context);
                  await _searchAndAddProduct();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Scan barcode using mobile_scanner.
  Future<void> _scanAndAddProduct() async {
    try {
      // Navigate to the scanner page and wait for a barcode result.
      final barcode = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
      );

      if (barcode == null || barcode.isEmpty) {
        // User cancelled scanning or no barcode detected.
        return;
      }
      // Fetch the product using the scanned barcode.
      final product = await _productRepository.fetchProduct(barcode);
      // ignore: unnecessary_null_comparison
      if (product != null) {
        await _promptAddProductDetail(product);
      } else {
        _showError('Product not found for barcode: $barcode');
      }
    } catch (e) {
      _showError('Error scanning barcode: $e');
    }
  }

  /// Search for a product using a search dialog.
  Future<void> _searchAndAddProduct() async {
    try {
      final allProducts = await _productRepository.fetchProducts();
      final selectedProduct = await showDialog<Product?>(
        context: context,
        builder: (context) {
          final TextEditingController searchController =
              TextEditingController();
          List<Product> filteredProducts = allProducts;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text('Search Product'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'Enter product name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (query) {
                          setState(() {
                            filteredProducts = allProducts
                                .where((p) => p.name
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 300,
                        width: double.maxFinite,
                        child: filteredProducts.isEmpty
                            ? const Center(child: Text('No products found'))
                            : ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return ListTile(
                                    title: Text(product.name),
                                    subtitle: Text(
                                      'Display Price: Rp${product.displayPrice.toStringAsFixed(0)}\nNet Price: Rp${product.netPrice.toStringAsFixed(0)}',
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, product);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (selectedProduct != null) {
        await _promptAddProductDetail(selectedProduct);
      }
    } catch (e) {
      _showError('Error searching products: $e');
    }
  }

  /// Prompt the user to enter quantity and agreed price for the selected product.
  Future<void> _promptAddProductDetail(Product product) async {
    final result = await showDialog<SalesProductItem>(
      context: context,
      builder: (context) {
        final quantityController = TextEditingController();
        final agreedPriceController = TextEditingController(
          text: product.displayPrice.toString(),
        );
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Add ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available stock: ${product.stock}'),
              const SizedBox(height: 8),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: agreedPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Agreed Price (Rp)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final int? quantity = int.tryParse(quantityController.text);
                final double? agreedPrice =
                    double.tryParse(agreedPriceController.text);
                if (quantity == null ||
                    quantity <= 0 ||
                    agreedPrice == null ||
                    agreedPrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Enter valid quantity and price')),
                  );
                  return;
                }
                if (quantity > product.stock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Quantity exceeds available stock for this product')),
                  );
                  return;
                }
                Navigator.pop(
                  context,
                  SalesProductItem(
                    product: product,
                    quantity: quantity,
                    agreedPrice: agreedPrice,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _salesItems.add(result);
      });
    }
  }

  /// Remove an item from the list.
  void _removeSalesItem(int index) {
    setState(() {
      _salesItems.removeAt(index);
    });
  }

  /// Submit the transaction along with its details.
  Future<void> _submitTransaction() async {
    if (_salesItems.isEmpty) {
      _showError('Please add at least one product');
      return;
    }
    try {
      final transactionPayload = {
        'date_created': _transactionDate.toIso8601String(),
        'note': _notesController.text,
      };
      final transaction = await _transactionRepository.addTransaction(
        transactionPayload,
      );

      for (var item in _salesItems) {
        final detailPayload = {
          'upc': item.product.upc,
          'quantity': item.quantity,
          'agreed_price': item.agreedPrice,
        };
        await _transactionDetailRepository.addTransactionDetail(
            transaction.transactionId, detailPayload);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Failed to submit transaction: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final String dateStr = DateFormat('yyyy-MM-dd').format(_transactionDate);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sale'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transaction Date Picker
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Transaction Date: $dateStr'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _transactionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _transactionDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ),
              // Optional Notes Field
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              // List of Added Products
              _salesItems.isEmpty
                  ? const Center(child: Text('No products added yet.'))
                  : Column(
                      children: _salesItems.asMap().entries.map((entry) {
                        int index = entry.key;
                        SalesProductItem item = entry.value;
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(item.product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Quantity: ${item.quantity} | Agreed Price: Rp${item.agreedPrice.toStringAsFixed(0)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeSalesItem(index),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 16),
              // Display Total Agreed Price
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Text(
                    'Total Agreed Price: Rp${_totalAgreedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Submit Button
              ElevatedButton.icon(
                onPressed: _submitTransaction,
                icon: const Icon(Icons.save),
                label: const Text('Submit Transaction'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProductOptions,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A dedicated page for scanning barcodes using the mobile_scanner package.
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        // Stop further detection before popping.
        _controller.stop();
        Navigator.of(context).pop(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}
