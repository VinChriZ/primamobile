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
  final Product product;
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
            ),
            dialogTheme: const DialogTheme(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.maxFinite,
                  constraints:
                      const BoxConstraints(maxWidth: 500, maxHeight: 600),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      const Text(
                        'Search Product',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Search box with icon
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Enter product name',
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
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
                      ),

                      const SizedBox(height: 12),

                      // Product count
                      Text(
                        '${filteredProducts.length} products found',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Products list
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No products found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return Card(
                                    elevation: 1,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      title: Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Available Stock: ${product.stock}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(context, product);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 8),

                      // Cancel button
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
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
    final quantityController = TextEditingController(text: "1");
    String? errorMessage;

    final result = await showDialog<ReportDetailItem>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
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
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: const OutlineInputBorder(),
                    errorText: errorMessage,
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
                    setState(() {
                      errorMessage = 'Enter valid quantity';
                    });
                    return;
                  }

                  // Only validate stock limit for "return" type reports
                  if (_selectedType == "return" && quantity > product.stock) {
                    setState(() {
                      errorMessage = 'Quantity exceeds stock';
                    });
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
        });
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
    String? errorMessage;

    final result = await showDialog<ReportDetailItem>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
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
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: const OutlineInputBorder(),
                    errorText: errorMessage,
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
                    setState(() {
                      errorMessage = 'Enter valid quantity';
                    });
                    return;
                  }

                  // Only validate stock limit for "return" type reports
                  if (_selectedType == "return" &&
                      quantity > item.product.stock) {
                    setState(() {
                      errorMessage = 'Quantity exceeds stock';
                    });
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
        });
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
      appBar: AppBar(
        title: const Text("Add Report"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Report Date Card - Blue outline
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade400, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withAlpha(128),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  title: const Text(
                    'Report Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ),

              // Report Type Card - Purple outline
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade400, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade100.withAlpha(128),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.description,
                            color: Colors.purple.shade700,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Report Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(
                            value: "restock", child: Text("Restock")),
                        DropdownMenuItem(
                            value: "return", child: Text("Return")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Notes Field - Yellow outline
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade400, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.shade100.withAlpha(128),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.note_alt,
                            color: Colors.amber.shade700,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Notes (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about this report...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              // Products Section with green outline for entire container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade400, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade100.withAlpha(128),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Products Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Report Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_reportDetails.length} items',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // List of Added Products or centered text if empty
                    _reportDetails.isEmpty
                        ? SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No products added yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add products',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reportDetails.length,
                            itemBuilder: (context, index) {
                              final item = _reportDetails[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.grey.shade300.withAlpha(128),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Qty: ${item.quantity}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _editReportDetail(index),
                                              icon: Icon(
                                                Icons.edit,
                                                size: 16,
                                                color: Colors.blue.shade700,
                                              ),
                                              label: Text(
                                                'Edit',
                                                style: TextStyle(
                                                    color:
                                                        Colors.blue.shade700),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color:
                                                        Colors.blue.shade200),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  _reportDetails
                                                      .removeAt(index);
                                                });
                                              },
                                              icon: Icon(
                                                Icons.delete_outline,
                                                size: 16,
                                                color: Colors.red.shade700,
                                              ),
                                              label: Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.red.shade700),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color: Colors.red.shade200),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),

              // Total Quantity Section (if there are items)
              if (_reportDetails.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withAlpha(128),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Items:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _reportDetails
                            .fold(0, (sum, item) => sum + item.quantity)
                            .toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Submit Button
              ElevatedButton.icon(
                onPressed: _reportDetails.isEmpty ? null : _submitReport,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Submit Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),

              // Extra space at bottom for FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProductOptions,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
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
