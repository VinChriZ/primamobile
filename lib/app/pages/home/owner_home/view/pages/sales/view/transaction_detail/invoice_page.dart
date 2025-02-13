import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/models/transaction/transaction_detail.dart';
import 'package:primamobile/repository/product_repository.dart';

class InvoicePrintPreviewPage extends StatelessWidget {
  final Transaction transaction;
  final List<TransactionDetail> details;

  const InvoicePrintPreviewPage({
    Key? key,
    required this.transaction,
    required this.details,
  }) : super(key: key);

  // Helper widget to build a row for invoice info.
  Widget _buildRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8.0),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Build the invoice header with transaction information.
  Widget _buildHeader() {
    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Invoice',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        _buildRow(label: 'Date:', value: dateStr),
        _buildRow(
          label: 'Total Agreed Price:',
          value: 'Rp${transaction.totalAgreedPrice.toStringAsFixed(0)}',
        ),
        _buildRow(
          label: 'Quantity:',
          value: transaction.quantity.toString(),
        ),
        if (transaction.note != null && transaction.note!.isNotEmpty)
          _buildRow(label: 'Note:', value: transaction.note!),
        const Divider(),
      ],
    );
  }

  // Build a card for each transaction detail using the ProductRepository
  // to fetch and display the product name.
  Widget _buildDetailItem(BuildContext context, TransactionDetail detail) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);

    return FutureBuilder(
      future: productRepository.fetchProduct(detail.upc),
      builder: (context, snapshot) {
        String productName = detail.upc; // fallback
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(title: Text('Loading product...')),
          );
        } else if (snapshot.hasError) {
          productName = detail.upc;
        } else if (snapshot.hasData) {
          // Assuming the fetched product model has a 'name' property.
          final product = snapshot.data!;
          productName = product.name;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(productName),
            subtitle: Text(
                'Quantity: ${detail.quantity} \nAgreed Price: Rp${detail.agreedPrice.toStringAsFixed(0)}'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16.0),
            const Text(
              'Transaction Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ...details
                .map((detail) => _buildDetailItem(context, detail))
                .toList(),
            const SizedBox(height: 20.0),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Replace with your actual print functionality.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Printing invoice...')),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print Invoice'),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Replace with your PDF export functionality.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting to PDF...')),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export to PDF'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
