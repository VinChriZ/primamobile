import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerScreen({
    required this.onBarcodeScanned,
    super.key,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  // Optionally, you could track duplicates if needed.
  String? _lastScannedCode;

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      // Only proceed if we have a valid code and it's different from the last scanned.
      if (code != null && code.isNotEmpty && code != _lastScannedCode) {
        _lastScannedCode = code;
        widget.onBarcodeScanned(code);
        Navigator.pop(context, code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: _onBarcodeDetected,
      ),
    );
  }
}
