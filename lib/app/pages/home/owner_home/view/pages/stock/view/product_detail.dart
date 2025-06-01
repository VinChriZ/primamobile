import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates and numbers
import 'package:primamobile/app/models/product/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  /// Helper widget to build a row for a given label/value pair.
  Widget _buildAttributeRow(String label, String value, {IconData? icon}) {
    // Extract the base label without the colon
    String baseLabel =
        label.endsWith(':') ? label.substring(0, label.length - 1) : label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color:
                    Colors.blue.withAlpha(25), // Updated from withOpacity(0.1)
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.blue[800],
              ),
            ),
          const SizedBox(width: 12),
          Container(
            width: 100,
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              baseLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16, // Reduced from 18
                color: Color(0xFF2E4057),
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            ":",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16, // Reduced from 18
              color: Color(0xFF2E4057),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16, // Reduced from 18
                color: Colors.black, // Changed from Color(0xFF33658A) to black
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format prices and dates
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0, // Set decimal digits to 0 to remove the ,00
    );
    final dateFormatter = DateFormat.yMMMMd().add_jm();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name Header with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withAlpha(76), // Updated from withOpacity(0.3)
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
              child: Column(
                children: [
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withAlpha(76), // Updated from withOpacity(0.3)
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details Section
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withAlpha(51), // Updated from withOpacity(0.2)
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Product Information',
                          style: TextStyle(
                            fontSize: 18, // Reduced from 20
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E4057),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // UPC
                        _buildAttributeRow('UPC', product.upc,
                            icon: Icons.qr_code),

                        // Stock with color based on level
                        _buildAttributeRow(
                          'Stock',
                          product.stock.toString(),
                          icon: Icons.inventory,
                        ),

                        // Net Price - removed divider and pricing title
                        _buildAttributeRow(
                          'Net Price',
                          currencyFormatter.format(product.netPrice),
                          icon: Icons.price_change,
                        ),

                        // Display Price
                        _buildAttributeRow(
                          'Display Price',
                          currencyFormatter.format(product.displayPrice),
                          icon: Icons.attach_money,
                        ),

                        // Category - removed divider and classification title
                        _buildAttributeRow(
                          'Category',
                          product.category,
                          icon: Icons.category,
                        ),

                        // Brand
                        _buildAttributeRow(
                          'Brand',
                          product.brand,
                          icon: Icons.branding_watermark,
                        ),

                        if (product.lastUpdated != null) const Divider(),

                        // Last Updated
                        if (product.lastUpdated != null)
                          _buildAttributeRow(
                            'Last Updated',
                            dateFormatter.format(product.lastUpdated!),
                            icon: Icons.update,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stock Status Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStockStatusColor(product.stock),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStockStatusIcon(product.stock),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _getStockStatusMessage(product.stock),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Reduced from 16
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for stock status
  Color _getStockStatusColor(int stock) {
    if (stock <= 5) {
      return Colors.red[700]!;
    } else if (stock <= 20) {
      return Colors.orange[700]!;
    } else {
      return Colors.green[700]!;
    }
  }

  IconData _getStockStatusIcon(int stock) {
    if (stock <= 5) {
      return Icons.warning_amber_rounded;
    } else if (stock <= 20) {
      return Icons.info_outline;
    } else {
      return Icons.check_circle_outline;
    }
  }

  String _getStockStatusMessage(int stock) {
    if (stock <= 0) {
      return 'Out of stock! Place an order immediately.';
    } else if (stock <= 3) {
      return 'Low stock! Consider placing an order soon.';
    } else if (stock <= 20) {
      return 'Stock level is moderate. Monitor inventory.';
    } else {
      return 'Stock level is good.';
    }
  }
}
