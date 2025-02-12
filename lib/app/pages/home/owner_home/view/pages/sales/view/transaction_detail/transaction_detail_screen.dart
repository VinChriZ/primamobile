import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/models/transaction/transaction_detail.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/transaction_detail/transaction_detail_bloc.dart';
import 'package:primamobile/repository/product_repository.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  /// Helper to build header attribute row with a fixed-width label and right-aligned value.
  Widget _buildTransactionInfoRow(
      {required String label, required String value}) {
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
                  // Optionally, display an error message or fallback to UPC
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                } else if (snapshot.hasData) {
                  // Assuming the Product model has a 'name' field
                  final product = snapshot.data!;
                  return Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                } else {
                  // Fallback in case no data is returned
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
            // Row with Edit and Delete buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showEditDetailDialog(context, detail),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showDeleteDetailConfirmation(
                        context, transactionId, detail.detailId),
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

  /// Dialog for adding a new detail.
  void _showAddDetailDialog(BuildContext context, int transactionId) {
    final _formKey = GlobalKey<FormState>();
    String upc = '';
    int quantity = 1;
    double agreedPrice = 0.0;
    final transactionDetailBloc = context.read<TransactionDetailBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: transactionDetailBloc,
          child: AlertDialog(
            title: const Text('Add Transaction Detail'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
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
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      initialValue: '1',
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
                      AddTransactionDetail(
                        transactionId,
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
                        content: Text('Transaction detail added successfully.'),
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
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
                            Text('Transaction detail updated successfully.'),
                      ),
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
                  transactionDetailBloc
                      .add(DeleteTransactionDetail(transactionId, detailId));
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

  @override
  Widget build(BuildContext context) {
    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];

    return Scaffold(
      // App bar title is only the date, centered.
      appBar: AppBar(
        title: Text(dateStr),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionDetailBloc, TransactionDetailState>(
        builder: (context, state) {
          if (state is TransactionDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionDetailLoaded) {
            // Use the updated header info from the bloc state.
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
                  // Display the note as a textbox with a black border (if it exists).
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
                  // Product List label before the details list.
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
            _showAddDetailDialog(context, transaction.transactionId),
        child: const Icon(Icons.add),
      ),
    );
  }
}
