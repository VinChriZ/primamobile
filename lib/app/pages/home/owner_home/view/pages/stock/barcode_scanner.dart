import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatelessWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerScreen({
    required this.onBarcodeScanned,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          final barcode = barcodeCapture.barcodes.first;
          if (barcode.rawValue != null) {
            final String scannedCode = barcode.rawValue!;
            onBarcodeScanned(scannedCode); // Pass the scanned code back
            Navigator.pop(context); // Close the scanner
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to scan barcode')),
            );
          }
        },
      ),
    );
  }
}
