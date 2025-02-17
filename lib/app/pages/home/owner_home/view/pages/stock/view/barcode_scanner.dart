import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
  @override
  void initState() {
    super.initState();
    _startBarcodeScan();
  }

  Future<void> _startBarcodeScan() async {
    try {
      // Initiate scanning using the flutter_barcode_scanner package.
      String scannedCode = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // scanning line color
        "Cancel", // cancel button text
        true, // show flash icon
        ScanMode.BARCODE, // scan mode: barcode
      );

      // If the user cancels the scan, the package returns '-1'.
      if (scannedCode != '-1' && scannedCode.isNotEmpty) {
        widget.onBarcodeScanned(scannedCode);
        Navigator.pop(context, scannedCode);
      } else {
        // User canceled the scan.
        Navigator.pop(context);
      }
    } catch (e) {
      // In case of any error, show a snackbar and pop the screen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan barcode')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple progress indicator while the scanning is in progress.
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
