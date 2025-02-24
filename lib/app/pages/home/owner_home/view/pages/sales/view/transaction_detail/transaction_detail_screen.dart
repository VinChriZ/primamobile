import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/models/transaction/transaction_detail.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/transaction_detail/transaction_detail_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/invoice_page.dart';
import 'package:primamobile/repository/product_repository.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  /// Helper to build header attribute row with a fixed-width label and right-aligned value.
  Widget _buildTransactionInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 200.0,
            child: Text(
              label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of transaction details.
  Widget _buildTransactionDetailsList(BuildContext context,
      List<TransactionDetail> details, int transactionId) {
    if (details.isEmpty) {
      return const Center(child: Text('No transaction details available.'));
    }
    return ListView.builder(
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return _buildTransactionDetailCard(context, detail, transactionId);
      },
    );
  }

  Widget _buildTransactionDetailCard(
      BuildContext context, TransactionDetail detail, int transactionId) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: productRepository.fetchProduct(detail.upc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Loading...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                } else if (snapshot.hasData) {
                  final product = snapshot.data!;
                  return Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                } else {
                  return Text(
                    detail.upc,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
            const SizedBox(height: 4.0),
            Text('Quantity: ${detail.quantity}'),
            const SizedBox(height: 2.0),
            Text('Agreed Price: Rp${detail.agreedPrice.toStringAsFixed(0)}'),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showEditDetailDialog(context, detail),
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
                        context, transaction.transactionId, detail.detailId),
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

  /// Dialog for editing an existing detail.
  void _showEditDetailDialog(BuildContext context, TransactionDetail detail) {
    final _formKey = GlobalKey<FormState>();
    String upc = detail.upc;
    int quantity = detail.quantity;
    double agreedPrice = detail.agreedPrice;
    final transactionDetailBloc = context.read<TransactionDetailBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: transactionDetailBloc,
          child: AlertDialog(
            title: const Text('Edit Transaction Detail'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
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
                    TextFormField(
                      initialValue: detail.agreedPrice.toStringAsFixed(2),
                      decoration:
                          const InputDecoration(labelText: 'Agreed Price'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter agreed price';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                      onSaved: (value) => agreedPrice = double.parse(value!),
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
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    transactionDetailBloc.add(
                      UpdateTransactionDetail(
                        transaction.transactionId,
                        detail.detailId,
                        {
                          'upc': upc,
                          'quantity': quantity,
                          'agreed_price': agreedPrice,
                        },
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Transaction detail updated successfully.')),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Confirmation dialog for deleting a detail.
  void _showDeleteDetailConfirmation(
      BuildContext context, int transactionId, int detailId) {
    final transactionDetailBloc = context.read<TransactionDetailBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: transactionDetailBloc,
          child: AlertDialog(
            title: const Text('Delete Transaction Detail'),
            content: const Text(
                'Are you sure you want to delete this transaction detail?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  transactionDetailBloc.add(DeleteTransactionDetail(
                      transaction.transactionId, detailId));
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Transaction detail deleted successfully.')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Opens a bottom sheet with options to scan a barcode or search for a product.
  void _openAddProductOptions(BuildContext context, int transactionId) {
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
                  await _scanAndAddProduct(context, transactionId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Product'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _searchAndAddProduct(context, transactionId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Uses the barcode scanner to scan a product and then adds it.
  Future<void> _scanAndAddProduct(
      BuildContext context, int transactionId) async {
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // scanning line color
        'Cancel',
        false,
        ScanMode.BARCODE,
      );
      if (barcode == '-1') return; // User cancelled.
      final productRepository =
          RepositoryProvider.of<ProductRepository>(context);
      final product = await productRepository.fetchProduct(barcode);
      // ignore: unnecessary_null_comparison
      if (product != null) {
        await _promptAddDetailDialog(context, product, transactionId);
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

  /// Opens a dialog to search for a product and then add it.
  Future<void> _searchAndAddProduct(
      BuildContext context, int transactionId) async {
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
        await _promptAddDetailDialog(context, selectedProduct, transactionId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: $e')),
      );
    }
  }

  /// Prompts the user to enter quantity and agreed price for the selected product.
  /// Once submitted, dispatches an AddTransactionDetail event.
  Future<void> _promptAddDetailDialog(
      BuildContext context, dynamic product, int transactionId) async {
    final quantityController = TextEditingController();
    final agreedPriceController =
        TextEditingController(text: product.displayPrice.toString());
    final transactionDetailBloc = context.read<TransactionDetailBloc>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: transactionDetailBloc,
          child: AlertDialog(
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
                onPressed: () => Navigator.pop(dialogContext),
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
                          content: Text('Quantity exceeds available stock')),
                    );
                    return;
                  }
                  transactionDetailBloc.add(
                    AddTransactionDetail(
                      transactionId,
                      {
                        'upc': product.upc,
                        'quantity': quantity,
                        'agreed_price': agreedPrice,
                      },
                    ),
                  );
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Transaction detail added successfully')),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: Text(dateStr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Invoice',
            onPressed: () {
              // Get the current bloc state
              final state = context.read<TransactionDetailBloc>().state;
              if (state is TransactionDetailLoaded) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InvoicePrintPreviewPage(
                      transaction: state.transaction,
                      details: state.details,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice not available yet.')),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionDetailBloc, TransactionDetailState>(
        builder: (context, state) {
          if (state is TransactionDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionDetailLoaded) {
            final updatedTransaction = state.transaction;
            final details = state.details;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _buildTransactionInfoRow(
                    label: 'Total Display Price:',
                    value:
                        'Rp${updatedTransaction.totalDisplayPrice.toStringAsFixed(0)}',
                  ),
                  _buildTransactionInfoRow(
                    label: 'Total Agreed Price:',
                    value:
                        'Rp${updatedTransaction.totalAgreedPrice.toStringAsFixed(0)}',
                  ),
                  _buildTransactionInfoRow(
                    label: 'Total Net Price:',
                    value:
                        'Rp${updatedTransaction.totalNetPrice.toStringAsFixed(0)}',
                  ),
                  _buildTransactionInfoRow(
                    label: 'Quantity:',
                    value: updatedTransaction.quantity.toString(),
                  ),
                  _buildTransactionInfoRow(
                    label: 'Date Created:',
                    value: updatedTransaction.dateCreated
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                  ),
                  _buildTransactionInfoRow(
                    label: 'Last Updated:',
                    value: updatedTransaction.lastUpdated
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                  ),
                  if (updatedTransaction.note != null &&
                      updatedTransaction.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          updatedTransaction.note!,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Product List:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: _buildTransactionDetailsList(
                        context, details, updatedTransaction.transactionId),
                  ),
                ],
              ),
            );
          } else if (state is TransactionDetailError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Unknown state.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _openAddProductOptions(context, transaction.transactionId),
        child: const Icon(Icons.add),
      ),
    );
  }
}
