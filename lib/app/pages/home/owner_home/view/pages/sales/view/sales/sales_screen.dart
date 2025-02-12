import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/sales/sales_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/transaction_detail_page.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

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

  /// Helper method to build a row for an attribute.
  /// The label is given a fixed width so the ":" is aligned.
  Widget _buildAttributeRow(String label, String value) {
    const double labelWidth = 120; // Adjust the width as needed
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    // Calculate profit as total agreed price minus total net price.
    double profit = transaction.totalAgreedPrice - transaction.totalNetPrice;
    // Format the date created (only the date part).
    String dateCreatedStr =
        transaction.dateCreated.toLocal().toString().split(' ')[0];
    // Format the last updated (without microseconds).
    String lastUpdatedStr =
        transaction.lastUpdated.toLocal().toString().split('.')[0];

    return Card(
      color: Colors.lightBlue[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(context, transaction),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: Date Created (bold and larger)
              Text(
                dateCreatedStr,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              // Display attributes using the helper method.
              _buildAttributeRow("Profit:", "Rp${profit.toStringAsFixed(0)}"),
              const SizedBox(height: 6.0),
              _buildAttributeRow("Quantity:", transaction.quantity.toString()),
              const SizedBox(height: 6.0),
              _buildAttributeRow("Last Updated:", lastUpdatedStr),
              const SizedBox(height: 12.0),
              // Long Delete Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: () => _showDeleteConfirmation(
                      context, transaction.transactionId),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          // Implement add transaction functionality if needed.
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
