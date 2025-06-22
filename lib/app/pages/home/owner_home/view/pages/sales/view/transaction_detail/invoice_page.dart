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
          SizedBox(
            width: 130.0,
            child: Text(
              label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 32.0),
          const Text(
            ':',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade600,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invoice',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12.0),
          _buildRow(label: 'Date', value: dateStr),
          _buildRow(
            label: 'Total Agreed Price',
            value: 'Rp${_formatCurrency(transaction.totalAgreedPrice)}',
          ),
          _buildRow(
            label: 'Quantity',
            value: transaction.quantity.toString(),
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty)
            _buildRow(label: 'Note', value: transaction.note!),
        ],
      ),
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
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: Colors.blue.shade600,
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRow(
                        label: 'Quantity',
                        value: detail.quantity.toString(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildRow(
                        label: 'Agreed Price',
                        value: 'Rp${_formatCurrency(detail.agreedPrice)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List> _generateInvoicePdf(BuildContext context) async {
    final pdf = pw.Document();
    final productRepository =
        RepositoryProvider.of<ProductRepository>(context, listen: false);

    pw.Widget buildPdfRow({required String label, required String value}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 120,
              child: pw.Text(label,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Expanded(
              child: pw.Text(value),
            ),
          ],
        ),
      );
    }

    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];
    final totalPrice = 'Rp${_formatCurrency(transaction.totalAgreedPrice)}';
    final quantity = transaction.quantity.toString();
    final note = transaction.note ?? '';

    final header = pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Invoice',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          buildPdfRow(label: 'Date:', value: dateStr),
          buildPdfRow(label: 'Total Agreed Price:', value: totalPrice),
          buildPdfRow(label: 'Quantity:', value: quantity),
          if (note.isNotEmpty) buildPdfRow(label: 'Note:', value: note),
        ],
      ),
    );

    List<pw.Widget> detailWidgets = [
      pw.SizedBox(height: 16),
      pw.Text('Transaction Details:',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
    ];

    for (var detail in details) {
      String productName;
      try {
        final product = await productRepository.fetchProduct(detail.upc);
        productName = product.name;
      } catch (_) {
        productName = detail.upc;
      }

      detailWidgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 4),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                productName,
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              buildPdfRow(label: 'Quantity:', value: '${detail.quantity}'),
              buildPdfRow(
                  label: 'Agreed Price:',
                  value: 'Rp${_formatCurrency(detail.agreedPrice)}'),
            ],
          ),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (_) => [header, ...detailWidgets],
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing invoice: $e')),
        );
      }
    }
  }

  void _printThermal(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Request Bluetooth permissions
      bool permissionsGranted = await BluetoothPermissionHelper.request();
      Navigator.of(context).pop(); // hide loader

      if (!permissionsGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Nearby devices permission required. Please enable in settings.'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
        return;
      }

      // Check Bluetooth
      bool isBluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isBluetoothEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enable Bluetooth on your device')),
        );
        return;
      }

      // Check connection
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isConnected) {
        final allPaired = await PrintBluetoothThermal.pairedBluetooths;

        if (allPaired.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No paired Bluetooth devices found')),
          );
          return;
        }

        // Filter to show only likely printer devices
        final printerDevices = allPaired.where((device) {
          final name = device.name.toLowerCase();
          return name.contains('print') ||
              name.contains('pos') ||
              name.contains('thermal') ||
              name.contains('receipt') ||
              name.contains('escpos') ||
              name.contains('esc') ||
              name.contains('ticket') ||
              name.contains('58mm') ||
              name.contains('80mm') ||
              name.contains('rpp') ||
              name.contains('bt') ||
              name.contains('pt-') ||
              name.contains('printer');
        }).toList();

        if (printerDevices.isEmpty) {
          // No printer devices found, ask user if they want to see all devices
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('No Printer Devices Found'),
              content: const Text(
                  'No Bluetooth printer devices were detected. Would you like to view all paired devices instead?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showDeviceSelectionDialog(context, allPaired, false);
                  },
                  child: const Text('Show All Devices'),
                ),
              ],
            ),
          );
          return;
        }

        // Show only printer devices
        await _showDeviceSelectionDialog(context, printerDevices, true);
      } else {
        // Already connected → print directly
        final bytes = await _generateThermalBytes();
        await PrintBluetoothThermal.writeBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Print completed')),
        );
      }
    } catch (e) {
      // Catch any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to printer: $e')),
      );
    }
  }

  // Helper method to show device selection dialog
  Future<void> _showDeviceSelectionDialog(BuildContext context,
      List<BluetoothInfo> devices, bool printersOnly) async {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                printersOnly ? 'Select Printer' : 'Select Bluetooth Device',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (!printersOnly)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Warning: Non-printer devices may not be compatible with thermal printing.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ),
              const Divider(),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (_, i) {
                    final device = devices[i];
                    return ListTile(
                      leading: const Icon(Icons.print, color: Colors.blue),
                      title: Text(
                        device.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(device.macAdress),
                      onTap: () async {
                        Navigator.of(ctx).pop(); // close selection
                        try {
                          // Show loader
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                                child: CircularProgressIndicator()),
                          );

                          final ok = await PrintBluetoothThermal.connect(
                              macPrinterAddress: device.macAdress);
                          if (!ok) throw Exception('Connect failed');

                          final bytes = await _generateThermalBytes();
                          final wrote =
                              await PrintBluetoothThermal.writeBytes(bytes);
                          if (!wrote) throw Exception('Write failed');

                          Navigator.of(context).pop(); // hide loader
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Print completed successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Navigator.of(context).pop(); // hide loader
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Printer Error: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
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
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<int>> _generateThermalBytes() async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(PaperSize.mm58, profile);
    final productRepo = ProductRepository();
    List<int> bytes = [];

    // ASCII-only helper
    String toAscii(String s) {
      final cleaned = s.replaceAll('…', '...');
      return String.fromCharCodes(
        cleaned.codeUnits.where((c) => c >= 0x20 && c <= 0x7E),
      );
    }

    // ——— Header ——————————————————————————————
    bytes += gen.text(
      toAscii('Prima Elektronik'),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += gen.text(
      toAscii('Jl. Raya Nomor 45'),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += gen.text('--------------------------------');
    bytes += gen.text(
      toAscii('INVOICE'),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
      ),
    );
    bytes += gen.text('--------------------------------');

    // ——— Date & Note ——————————————————————————————
    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];
    bytes += gen.text(toAscii('Tanggal       : $dateStr'));
    if ((transaction.note ?? '').isNotEmpty) {
      bytes += gen.text(toAscii('Catatan       : ${transaction.note}'));
    }
    bytes += gen.text('--------------------------------');

    // ——— Column headers ——————————————————————————
    bytes += gen.row([
      PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'Price',
        width: 4,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += gen.text('--------------------------------');

    // ——— Items with max two lines (words-based wrap) ——————————————————
    const int nameLimit = 16;

    for (var d in details) {
      // fetch & sanitize name
      String rawName;
      try {
        rawName = (await productRepo.fetchProduct(d.upc)).name;
      } catch (_) {
        rawName = d.upc;
      }
      final name = toAscii(rawName);

      // split into words & build up to two lines
      final words = name.split(' ');
      String line1 = '';
      String line2 = '';
      for (var w in words) {
        if ((line1.length + (line1.isEmpty ? 0 : 1) + w.length) <= nameLimit) {
          line1 = line1.isEmpty ? w : '$line1 $w';
        } else if ((line2.length + (line2.isEmpty ? 0 : 1) + w.length) <=
            nameLimit) {
          line2 = line2.isEmpty ? w : '$line2 $w';
        } else {
          break; // drop any overflow beyond two lines
        }
      }

      final qty = d.quantity.toString();
      final price = toAscii('Rp${_formatCurrency(d.agreedPrice)}');

      // first line with qty & price
      bytes += gen.row([
        PosColumn(text: line1, width: 6),
        PosColumn(
            text: qty,
            width: 2,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: price,
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      // optional second line (no indent)
      if (line2.isNotEmpty) {
        bytes += gen.text(line2);
      }
    } // ——— Footer with totals ——————————————————————————
    bytes += gen.text('--------------------------------');
    bytes += gen.row([
      PosColumn(
        text: 'Total',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: '${transaction.quantity}',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: toAscii('Rp${_formatCurrency(transaction.totalAgreedPrice)}'),
        width: 4,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += gen.text('--------------------------------');
    bytes += gen.text(
      toAscii('Terima kasih telah berbelanja!'),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += gen.feed(2);
    bytes += gen.cut();

    return bytes;
  }

  // Format currency with thousand separator
  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Preview'),
          elevation: 0,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _printInvoice(context),
                    icon: const Icon(Icons.print, color: Colors.black),
                    label: const Text('Print Invoice',
                        style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton.icon(
                    onPressed: () => _printThermal(context),
                    icon: const Icon(Icons.print_outlined, color: Colors.black),
                    label: const Text('Print Thermal Receipt',
                        style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
