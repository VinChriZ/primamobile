import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates and numbers
import 'package:primamobile/app/models/product/product.dart';
import 'package:primamobile/repository/product_repository.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductRepository _productRepository = ProductRepository();
  late Product _currentProduct;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  Future<void> _toggleProductStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_currentProduct.active) {
        await _productRepository.deactivateProduct(_currentProduct.upc);
      } else {
        await _productRepository.activateProduct(_currentProduct.upc);
      }

      setState(() {
        _currentProduct = Product(
          upc: _currentProduct.upc,
          name: _currentProduct.name,
          netPrice: _currentProduct.netPrice,
          displayPrice: _currentProduct.displayPrice,
          stock: _currentProduct.stock,
          category: _currentProduct.category,
          brand: _currentProduct.brand,
          active: !_currentProduct.active,
          lastUpdated: _currentProduct.lastUpdated,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_currentProduct.active
              ? 'Product activated successfully'
              : 'Product deactivated successfully'),
          backgroundColor:
              _currentProduct.active ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// widget to build a row
  Widget _buildAttributeRow(String label, String value, {IconData? icon}) {
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
                color: Colors.blue.withAlpha(25),
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
                fontSize: 16,
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
              fontSize: 16,
              color: Color(0xFF2E4057),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
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
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat.yMMMMd().add_jm();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name Header
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
                      color: Colors.grey.withAlpha(76),
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
                      _currentProduct.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(76),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentProduct.category,
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
                      color: Colors.grey.withAlpha(51),
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
                              fontSize: 18,
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
                          _buildAttributeRow('UPC', _currentProduct.upc,
                              icon: Icons.qr_code),

                          // Stock
                          _buildAttributeRow(
                            'Stock',
                            _currentProduct.stock.toString(),
                            icon: Icons.inventory,
                          ),

                          // Net Price
                          _buildAttributeRow(
                            'Net Price',
                            currencyFormatter.format(_currentProduct.netPrice),
                            icon: Icons.price_change,
                          ),

                          // Display Price
                          _buildAttributeRow(
                            'Display Price',
                            currencyFormatter
                                .format(_currentProduct.displayPrice),
                            icon: Icons.attach_money,
                          ),

                          // Category
                          _buildAttributeRow(
                            'Category',
                            _currentProduct.category,
                            icon: Icons.category,
                          ),

                          // Brand
                          _buildAttributeRow(
                            'Brand',
                            _currentProduct.brand,
                            icon: Icons.branding_watermark,
                          ),

                          _buildAttributeRow(
                            'Status',
                            _currentProduct.active ? 'Active' : 'Inactive',
                            icon: _currentProduct.active
                                ? Icons.check_circle
                                : Icons.cancel,
                          ),

                          if (_currentProduct.lastUpdated != null)
                            const Divider(),

                          // Last Updated
                          if (_currentProduct.lastUpdated != null)
                            _buildAttributeRow(
                              'Last Updated',
                              dateFormatter
                                  .format(_currentProduct.lastUpdated!),
                              icon: Icons.update,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Activate/Deactivate Button
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _toggleProductStatus,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          _currentProduct.active
                              ? Icons.block
                              : Icons.check_circle,
                          color: Colors.white,
                        ),
                  label: Text(
                    _isLoading
                        ? 'Processing...'
                        : (_currentProduct.active
                            ? 'Deactivate Product'
                            : 'Activate Product'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentProduct.active
                        ? Colors.red[600]
                        : Colors.green[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),

              // Stock Status Card
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStockStatusColor(_currentProduct.stock),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStockStatusIcon(_currentProduct.stock),
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getStockStatusMessage(_currentProduct.stock),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
    } else if (stock <= 5) {
      return 'Low stock! Consider placing an order soon.';
    } else if (stock <= 20) {
      return 'Stock level is moderate. Monitor inventory.';
    } else {
      return 'Stock level is good.';
    }
  }
}
