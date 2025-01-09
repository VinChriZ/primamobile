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
    // A flag to ensure the scanner does not pop the screen multiple times
    bool isPopped = false;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          if (isPopped) return;
          isPopped = true;
          final barcode = barcodeCapture.barcodes.first;
          if (barcode.rawValue != null) {
            final String scannedCode = barcode.rawValue!;
            onBarcodeScanned(scannedCode);
            Navigator.pop(context, scannedCode);
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
