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

  Widget _buildAttributeRow({required String label, required String value}) {
    // Updated to align label left with consistent spacing
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0, // Reduced from 15.0
                  color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
          const Text(
            ' : ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.0, // Reduced from 15.0
                color: Colors.black),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13.0, color: Colors.black), // Reduced from 15.0
            ),
          ),
        ],
      ),
    );
  }

  // Get color based on status for the card border
  Color _getStatusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade600;
      case 'disapproved':
        return Colors.red.shade600;
      case 'waiting':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _buildDetailCard(BuildContext context, ReportDetail detail) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);
    final bool isEditable = _isReportEditable;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side:
            BorderSide(color: _getStatusBorderColor(report.status), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fetch and display the product name instead of UPC.
            FutureBuilder(
              future: productRepository.fetchProduct(detail.upc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Loading product...'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final product = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?.name ?? detail.upc,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0, // Reduced from 16.0
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UPC: ${detail.upc}',
                        style: const TextStyle(
                          fontSize: 11.0, // Reduced from 12.0
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Text(
                    detail.upc,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0, // Reduced from 16.0
                      color: Colors.black,
                    ),
                  );
                }
              },
            ),
            const Divider(),
            Text(
              'Quantity: ${detail.quantity}',
              style: const TextStyle(
                  fontSize: 13.0, color: Colors.black), // Reduced from 15.0
            ),

            // Only show edit/delete buttons if the report is editable
            if (isEditable) ...[
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _showEditReportDetailDialog(context, report, detail),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showDeleteDetailConfirmation(
                          context, report, detail),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditReportDetailDialog(
      BuildContext context, Report report, ReportDetail detail) {
    final workerReportDetailBloc = context.read<WorkerReportDetailBloc>();
    final quantityController =
        TextEditingController(text: detail.quantity.toString());
    String? quantityErrorMessage;

    // Get the product to show available stock
    final productRepository = RepositoryProvider.of<ProductRepository>(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder(
          future: productRepository.fetchProduct(detail.upc),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final product = snapshot.data;

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Edit ${product?.name ?? detail.upc}'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Display the UPC as text but don't allow editing
                        Text(
                          'UPC: ${detail.upc}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Display available stock
                        if (product != null)
                          Text(
                            'Available stock: ${product.stock}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: const OutlineInputBorder(),
                            errorText: quantityErrorMessage,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final quantity =
                            int.tryParse(quantityController.text.trim());

                        // Validate quantity
                        if (quantity == null || quantity <= 0) {
                          setState(() {
                            quantityErrorMessage = 'Enter valid quantity';
                          });
                          return;
                        }

                        // Only validate stock limit for "return" type reports
                        if (report.type.toLowerCase() == "return" &&
                            product != null &&
                            quantity > product.stock) {
                          setState(() {
                            quantityErrorMessage =
                                'Quantity exceeds available stock';
                          });
                          return;
                        }

                        // All validations passed
                        workerReportDetailBloc.add(
                          UpdateWorkerReportDetail(
                            report.reportId,
                            detail.reportDetailId,
                            {
                              'upc': detail.upc, // Keep the original UPC
                              'quantity': quantity,
                            },
                          ),
                        );
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Report detail updated successfully.')),
                        );
                      },
                      child: const Text('Update'),
                    ),
                  ],
                );
              },
            );
          },
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
    final quantityController = TextEditingController(text: "1");
    final workerReportDetailBloc = context.read<WorkerReportDetailBloc>();
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (dialogContext) {
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
                onPressed: () => Navigator.pop(dialogContext),
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
                  if (report.type.toLowerCase() == "return" &&
                      quantity > product.stock) {
                    setState(() {
                      errorMessage = 'Quantity exceeds stock';
                    });
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('yyyy-MM-dd').format(report.dateCreated),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: BlocBuilder<WorkerReportDetailBloc, WorkerReportDetailState>(
        builder: (context, state) {
          if (state is WorkerReportDetailLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading report details...'),
                ],
              ),
            );
          } else if (state is WorkerReportDetailLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<WorkerReportDetailBloc>()
                    .add(FetchWorkerReportDetails(report.reportId));
              },
              child: Container(
                color: Colors.grey.shade50,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: _getStatusBorderColor(report.status),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Report Information',
                              style: TextStyle(
                                fontSize: 16.0, // Reduced from 18.0
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAttributeRow(
                              label: 'Type',
                              value: report.type,
                            ),
                            _buildAttributeRow(
                              label: 'Status',
                              value: report.status,
                            ),
                            _buildAttributeRow(
                              label: 'User ID',
                              value: report.userId.toString(),
                            ),
                            _buildAttributeRow(
                              label: 'Date Created',
                              value: DateFormat('yyyy-MM-dd')
                                  .format(report.dateCreated),
                            ),
                            _buildAttributeRow(
                              label: 'Last Updated',
                              value: DateFormat('yyyy-MM-dd HH:mm')
                                  .format(report.lastUpdated),
                            ),
                            if (report.note != null && report.note!.isNotEmpty)
                              _buildAttributeRow(
                                label: 'Note',
                                value: report.note!,
                              ),
                            // Remove the Edit Note button - users should use the EditReportPage instead
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Report Details',
                        style: TextStyle(
                          fontSize: 16, // Reduced from 18
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    state.details.isEmpty
                        ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 16),
                                  Text(
                                    'No report details available',
                                    style: TextStyle(
                                      fontSize: 14, // Reduced from 16
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: state.details
                                .map((detail) =>
                                    _buildDetailCard(context, detail))
                                .toList(),
                          ),
                  ],
                ),
              ),
            );
          } else if (state is WorkerReportDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black), // Reduced from 16
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<WorkerReportDetailBloc>()
                          .add(FetchWorkerReportDetails(report.reportId));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data.'));
        },
      ),
      // Only show the FAB if the report is editable
      floatingActionButton: _isReportEditable
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
