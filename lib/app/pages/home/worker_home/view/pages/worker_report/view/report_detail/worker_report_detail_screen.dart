import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/models/report/report_detail.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report_detail/bloc/worker_report_detail_bloc.dart';
import 'package:primamobile/repository/product_repository.dart';

class WorkerReportDetailScreen extends StatelessWidget {
  final Report report;

  const WorkerReportDetailScreen({super.key, required this.report});

  // Helper to check if the report is editable
  bool get _isReportEditable {
    final status = report.status.toLowerCase();
    return status != 'approved' && status != 'disapproved';
  }

  Widget _buildAttributeRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 150.0,
            child: Text(
              label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetailsList(
      BuildContext context, Report report, List<ReportDetail> details) {
    if (details.isEmpty) {
      return const Center(child: Text('No report details available.'));
    }
    return ListView.builder(
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return _buildReportDetailCard(context, report, detail);
      },
    );
  }

  Widget _buildReportDetailCard(
      BuildContext context, Report report, ReportDetail detail) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);
    final bool isEditable = _isReportEditable;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instead of showing UPC, fetch and show the product name.
            FutureBuilder(
              future: productRepository.fetchProduct(detail.upc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Loading...',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  );
                } else if (snapshot.hasData) {
                  final product = snapshot.data;
                  return Text(
                    product?.name ?? detail.upc,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  );
                } else {
                  return Text(
                    detail.upc,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  );
                }
              },
            ),
            const SizedBox(height: 4.0),
            Text(
              'Quantity: ${detail.quantity}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 12.0),
            // Only show edit/delete buttons if the report is editable
            if (isEditable)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _showEditReportDetailDialog(context, report, detail),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showDeleteDetailConfirmation(
                          context, report, detail),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showEditReportDetailDialog(
      BuildContext context, Report report, ReportDetail detail) {
    final formKey = GlobalKey<FormState>();
    String upc = detail.upc;
    int quantity = detail.quantity;
    final workerReportDetailBloc = context.read<WorkerReportDetailBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Report Detail'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: detail.upc,
                    decoration: const InputDecoration(labelText: 'UPC'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter UPC';
                      }
                      return null;
                    },
                    onSaved: (value) => upc = value!,
                  ),
                  TextFormField(
                    initialValue: detail.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Enter a valid quantity';
                      }
                      return null;
                    },
                    onSaved: (value) => quantity = int.parse(value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  workerReportDetailBloc.add(
                    UpdateWorkerReportDetail(
                      report.reportId,
                      detail.reportDetailId,
                      {
                        'upc': upc,
                        'quantity': quantity,
                      },
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Report detail updated successfully.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDetailConfirmation(
      BuildContext context, Report report, ReportDetail detail) {
    final workerReportDetailBloc = context.read<WorkerReportDetailBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Report Detail'),
          content:
              const Text('Are you sure you want to delete this report detail?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                workerReportDetailBloc.add(
                  DeleteWorkerReportDetail(
                      report.reportId, detail.reportDetailId),
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Report detail deleted successfully.')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // New functions to support adding a report detail (similar to the transaction detail screen).
  void _openAddProductOptions(BuildContext context, int reportId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan Barcode'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _scanAndAddProduct(context, reportId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Product'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _searchAndAddProduct(context, reportId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scanAndAddProduct(BuildContext context, int reportId) async {
    try {
      final barcode = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerPage(),
        ),
      );
      if (barcode == null || barcode.isEmpty) return;
      final productRepository =
          RepositoryProvider.of<ProductRepository>(context);
      final product = await productRepository.fetchProduct(barcode);
      // ignore: unnecessary_null_comparison
      if (product != null) {
        await _promptAddDetailDialog(context, product, reportId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning barcode: $e')),
      );
    }
  }

  Future<void> _searchAndAddProduct(BuildContext context, int reportId) async {
    try {
      final productRepository =
          RepositoryProvider.of<ProductRepository>(context);
      final allProducts = await productRepository.fetchProducts();
      final selectedProduct = await showDialog(
        context: context,
        builder: (dialogContext) {
          final TextEditingController searchController =
              TextEditingController();
          List<dynamic> filteredProducts = allProducts;
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
        await _promptAddDetailDialog(context, selectedProduct, reportId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: $e')),
      );
    }
  }

  Future<void> _promptAddDetailDialog(
      BuildContext context, dynamic product, int reportId) async {
    final quantityController = TextEditingController();
    final workerReportDetailBloc = context.read<WorkerReportDetailBloc>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
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
                workerReportDetailBloc.add(
                  AddWorkerReportDetail(reportId, {
                    'upc': product.upc,
                    'quantity': quantity,
                  }),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Report detail added successfully')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String reportDateStr =
        DateFormat('yyyy-MM-dd').format(report.dateCreated);
    final bool isEditable = _isReportEditable;

    return Scaffold(
      appBar: AppBar(
        title: Text(reportDateStr),
        centerTitle: true,
      ),
      body: BlocBuilder<WorkerReportDetailBloc, WorkerReportDetailState>(
        builder: (context, state) {
          if (state is WorkerReportDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkerReportDetailLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<WorkerReportDetailBloc>()
                    .add(FetchWorkerReportDetails(report.reportId));
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAttributeRow(
                    label: 'User ID:',
                    value: report.userId.toString(),
                  ),
                  _buildAttributeRow(
                    label: 'Date Created:',
                    value: DateFormat('yyyy-MM-dd').format(report.dateCreated),
                  ),
                  _buildAttributeRow(
                    label: 'Last Updated:',
                    value: DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(report.lastUpdated),
                  ),
                  _buildAttributeRow(
                    label: 'Type:',
                    value: report.type,
                  ),
                  _buildAttributeRow(
                    label: 'Status:',
                    value: report.status,
                    // Add color to status text based on the status
                    valueStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: report.status.toLowerCase() == 'waiting'
                          ? Colors.blue[700]
                          : report.status.toLowerCase() == 'approved'
                              ? Colors.green[700]
                              : report.status.toLowerCase() == 'disapproved'
                                  ? Colors.red[700]
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Product List:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 400, // Adjust height as needed.
                    child:
                        _buildReportDetailsList(context, report, state.details),
                  ),
                ],
              ),
            );
          } else if (state is WorkerReportDetailError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data.'));
        },
      ),
      // Only show the FAB if the report is editable
      floatingActionButton: isEditable
          ? FloatingActionButton(
              onPressed: () => _openAddProductOptions(context, report.reportId),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// A minimal BarcodeScannerPage for demonstration purposes.
// In your actual app, implement barcode scanning using mobile_scanner or a similar package.
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
        // Stop scanning to prevent further detections.
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
