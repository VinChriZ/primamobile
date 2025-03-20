import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/models.dart'; // Ensure this includes Product & Report models
import 'package:primamobile/repository/report_repository.dart';
import 'package:primamobile/repository/report_detail_repository.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/utils/globals.dart';

class ReportDetailItem {
  final Product
      product; // Changed from just the UPC to include the full product
  final int quantity;

  ReportDetailItem({required this.product, required this.quantity});

  @override
  String toString() => 'Product: ${product.name}, Quantity: $quantity';
}

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  _AddReportPageState createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _reportDate = DateTime.now();
  String _selectedType = "restock"; // "restock" or "return"
  final TextEditingController _noteController = TextEditingController();
  // Report status is fixed to "waiting".
  final List<ReportDetailItem> _reportDetails = [];

  late final ReportRepository _reportRepository;
  late final ReportDetailRepository _reportDetailRepository;
  late final ProductRepository _productRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reportRepository = RepositoryProvider.of<ReportRepository>(context);
    _reportDetailRepository =
        RepositoryProvider.of<ReportDetailRepository>(context);
    _productRepository = RepositoryProvider.of<ProductRepository>(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _reportDate) {
      setState(() {
        _reportDate = picked;
      });
    }
  }

  /// Opens a bottom sheet with options to scan a barcode or search for a product.
  void _openAddProductOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
      final barcode = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
      );

      if (barcode == null || barcode.isEmpty) return;

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

  /// Prompts the user to enter a quantity for the selected product.
  Future<void> _promptAddProductDetail(Product product) async {
    final quantityController =
        TextEditingController(text: "1"); // Set default to 1
    final result = await showDialog<ReportDetailItem>(
      context: context,
      builder: (context) {
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
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter valid quantity')),
                  );
                  return;
                }
                if (quantity > product.stock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Quantity exceeds available stock')),
                  );
                  return;
                }
                Navigator.pop(
                  context,
                  ReportDetailItem(
                    product: product,
                    quantity: quantity,
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
        _reportDetails.add(result);
      });
    }
  }

  /// Edit an existing report detail
  void _editReportDetail(int index) async {
    final item = _reportDetails[index];
    final quantityController =
        TextEditingController(text: item.quantity.toString());

    final result = await showDialog<ReportDetailItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Edit ${item.product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available stock: ${item.product.stock}'),
              const SizedBox(height: 8),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
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
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter valid quantity')),
                  );
                  return;
                }
                if (quantity > item.product.stock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Quantity exceeds available stock')),
                  );
                  return;
                }
                Navigator.pop(
                  context,
                  ReportDetailItem(
                    product: item.product,
                    quantity: quantity,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _reportDetails[index] = result;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_reportDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please add at least one report detail")));
      return;
    }

    final String note = _noteController.text.trim();
    final reportPayload = {
      'user_id': Globals.userSession.user.userId,
      'date_created': _reportDate.toIso8601String(),
      'type': _selectedType,
      'status': 'waiting', // Always "waiting"
    };

    // Add note to payload if it's not empty
    if (note.isNotEmpty) {
      reportPayload['note'] = note;
    }

    try {
      final report = await _reportRepository.addReport(reportPayload);
      for (var detail in _reportDetails) {
        final detailPayload = {
          'upc': detail.product.upc,
          'quantity': detail.quantity,
        };
        await _reportDetailRepository.addReportDetail(
            report.reportId, detailPayload);
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report added successfully")));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to submit report: $e")));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_reportDate);
    return Scaffold(
      appBar: AppBar(title: const Text("Add Report"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text("Report Date: $formattedDate"),
                  trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _selectDate(context)),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Report Type",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(
                          value: "restock", child: Text("Restock")),
                      DropdownMenuItem(value: "return", child: Text("Return")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: "Note (Optional)",
                      border: OutlineInputBorder(),
                      hintText: "Add a note about this report",
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Report Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _reportDetails.isEmpty
                  ? const Center(child: Text("No report details added yet."))
                  : Column(
                      children: _reportDetails.asMap().entries.map((entry) {
                        int index = entry.key;
                        ReportDetailItem item = entry.value;
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const Divider(),
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                                const SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _editReportDetail(index),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Edit'),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _reportDetails.removeAt(index);
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 16),
              // Submit Report Button
              ElevatedButton.icon(
                onPressed: _submitReport,
                icon: const Icon(Icons.save),
                label: const Text("Submit Report"),
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
