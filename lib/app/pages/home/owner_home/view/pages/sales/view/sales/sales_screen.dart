import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/sales/sales_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/transaction_detail_page.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({Key? key}) : super(key: key);

  void _navigateToDetail(BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(transaction: transaction),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int transactionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SalesBloc>().add(DeleteTransaction(transactionId));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Transaction deleted successfully.')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTransactionDialog(
      BuildContext context, Transaction transaction) {
    final _formKey = GlobalKey<FormState>();
    double totalDisplayPrice = transaction.totalDisplayPrice;
    DateTime dateCreated = transaction.dateCreated;
    String? note = transaction.note;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: transaction.totalDisplayPrice.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Total Display Price'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter total display price';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      totalDisplayPrice = double.parse(value!);
                    },
                  ),
                  TextFormField(
                    initialValue: transaction.dateCreated.toIso8601String(),
                    decoration: const InputDecoration(
                        labelText: 'Date Created (ISO 8601)'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: transaction.dateCreated,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        dateCreated = pickedDate;
                        // Force rebuild the dialog
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: transaction.note,
                    decoration: const InputDecoration(labelText: 'Note'),
                    onSaved: (value) {
                      note = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Prepare fields map
                  Map<String, dynamic> fields = {
                    'total_display_price': totalDisplayPrice,
                    'date_created': dateCreated.toIso8601String(),
                  };
                  if (note != null && note!.isNotEmpty) {
                    fields['note'] = note!;
                  }
                  // Implement update functionality
                  // For example, navigate to an edit screen or directly call repository
                  // Here, you might need to implement an EditTransaction event in SalesBloc
                  // Currently, the SalesBloc does not handle an EditTransaction event
                  // You may need to extend the SalesBloc accordingly
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Edit functionality not implemented yet.')),
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

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text('Transaction #${transaction.transactionId}'),
        subtitle: Text(
            'Total Price: \$${transaction.totalDisplayPrice.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditTransactionDialog(context, transaction),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _showDeleteConfirmation(context, transaction.transactionId),
            ),
          ],
        ),
        onTap: () => _navigateToDetail(context, transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SalesLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(child: Text('No transactions available.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SalesBloc>().add(FetchSales());
              },
              child: ListView.builder(
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = state.transactions[index];
                  return _buildTransactionCard(context, transaction);
                },
              ),
            );
          } else if (state is SalesError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Unknown state.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add transaction functionality
          // For example, navigate to a new transaction creation page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Add Transaction functionality not implemented yet.')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
