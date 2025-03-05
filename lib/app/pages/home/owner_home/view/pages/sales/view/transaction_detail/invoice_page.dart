import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/models/transaction/transaction_detail.dart';
import 'package:primamobile/repository/product_repository.dart';

// PDF, printing, and sharing packages.
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class InvoicePrintPreviewPage extends StatelessWidget {
  final Transaction transaction;
  final List<TransactionDetail> details;

  const InvoicePrintPreviewPage({
    super.key,
    required this.transaction,
    required this.details,
  });

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

  /// Generate the invoice PDF document.
  Future<Uint8List> _generateInvoicePdf(BuildContext context) async {
    final pdf = pw.Document();
    final productRepository =
        RepositoryProvider.of<ProductRepository>(context, listen: false);

    // Helper function to build a row in the PDF.
    pw.Widget _buildPdfRow({required String label, required String value}) {
      return pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: pw.Text(value)),
        ],
      );
    }

    // Format transaction info.
    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];
    final totalPrice = 'Rp${transaction.totalAgreedPrice.toStringAsFixed(0)}';
    final quantity = transaction.quantity.toString();
    final note = transaction.note ?? '';

    // Build the invoice header.
    final header = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Invoice',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        _buildPdfRow(label: 'Date:', value: dateStr),
        _buildPdfRow(label: 'Total Agreed Price:', value: totalPrice),
        _buildPdfRow(label: 'Quantity:', value: quantity),
        if (note.isNotEmpty) _buildPdfRow(label: 'Note:', value: note),
        pw.Divider(),
      ],
    );

    // Build list of transaction details.
    List<pw.Widget> detailWidgets = [];
    detailWidgets.add(
      pw.Text('Transaction Details:',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
    );
    detailWidgets.add(pw.SizedBox(height: 8));

    // For each detail, try to fetch the product name.
    for (var detail in details) {
      String productName;
      try {
        final product = await productRepository.fetchProduct(detail.upc);
        productName = product.name;
      } catch (e) {
        productName = detail.upc;
      }

      detailWidgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 4),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(productName,
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Quantity: ${detail.quantity}'),
              pw.Text(
                  'Agreed Price: Rp${detail.agreedPrice.toStringAsFixed(0)}'),
            ],
          ),
        ),
      );
    }

    // Create a multipage PDF.
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return <pw.Widget>[
            header,
            pw.SizedBox(height: 16),
            ...detailWidgets,
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Print the invoice using the printing package.
  void _printInvoice(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async =>
            await _generateInvoicePdf(context),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing invoice: $e')),
      );
    }
  }

  /// Export the invoice to a PDF file and share it.
  void _exportToPdf(BuildContext context) async {
    try {
      final pdfData = await _generateInvoicePdf(context);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice.pdf');
      await file.writeAsBytes(pdfData);
      await Share.shareXFiles([XFile(file.path)], text: 'Invoice PDF');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PDF: $e')),
      );
    }
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
            ...details.map((detail) => _buildDetailItem(context, detail)),
            const SizedBox(height: 20.0),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _printInvoice(context),
                    icon: const Icon(Icons.print),
                    label: const Text('Print Invoice'),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton.icon(
                    onPressed: () => _exportToPdf(context),
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
