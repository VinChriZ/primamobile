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
import 'package:primamobile/utils/helpers/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Bluetooth printer packages
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class InvoicePrintPreviewPage extends StatelessWidget {
  final Transaction transaction;
  final List<TransactionDetail> details;

  const InvoicePrintPreviewPage({
    super.key,
    required this.transaction,
    required this.details,
  });

  Widget _buildRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8.0),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

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

  Widget _buildDetailItem(BuildContext context, TransactionDetail detail) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);

    return FutureBuilder(
      future: productRepository.fetchProduct(detail.upc),
      builder: (context, snapshot) {
        String productName = detail.upc;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(title: Text('Loading product...')),
          );
        } else if (snapshot.hasError) {
          productName = detail.upc;
        } else if (snapshot.hasData) {
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

  Future<Uint8List> _generateInvoicePdf(BuildContext context) async {
    final pdf = pw.Document();
    final productRepository =
        RepositoryProvider.of<ProductRepository>(context, listen: false);

    pw.Widget _buildPdfRow({required String label, required String value}) {
      return pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: pw.Text(value)),
        ],
      );
    }

    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];
    final totalPrice = 'Rp${transaction.totalAgreedPrice.toStringAsFixed(0)}';
    final quantity = transaction.quantity.toString();
    final note = transaction.note ?? '';

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

    List<pw.Widget> detailWidgets = [];
    detailWidgets.add(
      pw.Text('Transaction Details:',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
    );
    detailWidgets.add(pw.SizedBox(height: 8));

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

  void _printThermal(BuildContext context) async {
    try {
      // First show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Request Bluetooth permissions
      bool permissionsGranted = await BluetoothPermissionHelper.request();

      // Close the loading indicator
      Navigator.of(context).pop();

      if (!permissionsGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Nearby devices permission required. Please enable in settings.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }

      // Explicitly check Bluetooth status
      bool isBluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isBluetoothEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enable Bluetooth on your device')),
        );
        return;
      }

      // Check if already connected to a printer
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isConnected) {
        // Get paired devices
        List<BluetoothInfo> pairedDevices =
            await PrintBluetoothThermal.pairedBluetooths;

        if (pairedDevices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No paired Bluetooth printers found')),
          );
          return;
        }

        // Show device selection dialog with improved design
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Select Printer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: pairedDevices.length,
                      itemBuilder: (context, index) {
                        final device = pairedDevices[index];
                        return ListTile(
                          leading: const Icon(Icons.print, color: Colors.blue),
                          title: Text(
                            device.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(device.macAdress),
                          onTap: () async {
                            Navigator.of(context).pop();

                            // Show connecting indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                content: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Row(
                                    children: const [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 24),
                                      Text(
                                        'Connecting...',
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );

                            try {
                              bool result = await PrintBluetoothThermal.connect(
                                  macPrinterAddress: device.macAdress);

                              // Close the connecting dialog
                              Navigator.of(context).pop();

                              if (result) {
                                List<int> bytes = await _generateThermalBytes();
                                await PrintBluetoothThermal.writeBytes(bytes);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Print completed successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Failed to connect to printer'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Close the connecting dialog if still showing
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          trailing: const Icon(Icons.chevron_right),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Already connected to a printer, directly print
        List<int> bytes = await _generateThermalBytes();
        await PrintBluetoothThermal.writeBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Print completed')),
        );
      }
    } catch (e) {
      // Show the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to printer: $e')),
      );
    }
  }

  Future<List<int>> _generateThermalBytes() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text('Invoice',
        styles: const PosStyles(
            align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.text('------------------------');

    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];
    bytes += generator.text('Date: $dateStr');
    bytes += generator
        .text('Total: Rp${transaction.totalAgreedPrice.toStringAsFixed(0)}');
    bytes += generator.text('Qty: ${transaction.quantity}');
    if (transaction.note != null && transaction.note!.isNotEmpty) {
      bytes += generator.text('Note: ${transaction.note}');
    }

    bytes += generator.text('------------------------');
    for (var detail in details) {
      bytes += generator.text('${detail.upc}');
      bytes += generator.text('Qty: ${detail.quantity} '
          'Rp${detail.agreedPrice.toStringAsFixed(0)}');
    }

    bytes += generator.text('------------------------');
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
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
                  const SizedBox(height: 10.0),
                  ElevatedButton.icon(
                    onPressed: () => _printThermal(context),
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Print Thermal Receipt'),
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
