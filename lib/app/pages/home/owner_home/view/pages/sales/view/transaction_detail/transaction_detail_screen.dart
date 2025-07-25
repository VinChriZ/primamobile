import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // New import
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/models/transaction/transaction_detail.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/transaction_detail/transaction_detail_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/invoice_page.dart';
import 'package:primamobile/repository/product_repository.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  // Add currency formatting helper
  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Widget _buildTransactionInfoRow({
    required String label,
    required String value,
  }) {
    // Updated to align label left with consistent spacing
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey
                .withAlpha(26), // Changed from withOpacity to withAlpha
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
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
          const Text(
            ' : ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
          ),
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

  Widget _buildTransactionDetailsList(BuildContext context,
      List<TransactionDetail> details, int transactionId) {
    if (details.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No transaction details available.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true, // Allow ListView to size based on content
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling of nested ListView
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return _buildTransactionDetailCard(context, detail, transactionId);
      },
    );
  }

  Widget _buildTransactionDetailCard(
      BuildContext context, TransactionDetail detail, int transactionId) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: productRepository.fetchProduct(detail.upc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Loading product...'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final product = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      detail.upc,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }
              },
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Qty: ${detail.quantity}',
                  style: const TextStyle(fontSize: 14.0),
                ),
                Text(
                  'Agreed Price: Rp${_formatCurrency(detail.agreedPrice)}',
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showEditDetailDialog(context, detail),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showDeleteDetailConfirmation(
                        context, transaction.transactionId, detail.detailId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDetailDialog(BuildContext context, TransactionDetail detail) {
    String upc = detail.upc; // Keep this variable for backend communication
    int quantity = detail.quantity;
    double agreedPrice = detail.agreedPrice;
    final transactionDetailBloc = context.read<TransactionDetailBloc>();
    String? errorMessage;
    final productRepository = RepositoryProvider.of<ProductRepository>(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: transactionDetailBloc,
          child: FutureBuilder(
              future: productRepository.fetchProduct(upc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AlertDialog(
                    content: Center(child: CircularProgressIndicator()),
                  );
                }

                final product = snapshot.data;
                // Calculate the maximum quantity allowed (current stock + current quantity in this transaction)
                final availableStock = (product?.stock ?? 0) + detail.quantity;

                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Edit Transaction Detail'),
                    content: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                        maxWidth: double.maxFinite,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (snapshot.hasData)
                              Text('Available stock: ${product!.stock}'),
                            if (snapshot.hasData)
                              Text(
                                  'Net price: Rp${_formatCurrency(product!.netPrice)}'),
                            const SizedBox(height: 12),

                            // Quantity SpinBox
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quantity:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height: 36, // Height for better tap target
                                  alignment: Alignment
                                      .center, // Center content vertically
                                  child: SpinBox(
                                    min: 1,
                                    max: availableStock.toDouble(),
                                    value: quantity.toDouble(),
                                    decimals: 0,
                                    step: 1,
                                    textAlign: TextAlign
                                        .center, // Center the value text
                                    iconSize:
                                        22, // Smaller icons for better alignment
                                    spacing:
                                        1, // Reduce spacing between elements
                                    decoration: const InputDecoration.collapsed(
                                      hintText: '',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        quantity = value.toInt();
                                        if (errorMessage != null) {
                                          errorMessage = null;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16), // Agreed Price SpinBox
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Agreed Price (Rp):',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height: 36, // Height for better tap target
                                  alignment: Alignment
                                      .center, // Center content vertically
                                  child: SpinBox(
                                    min: 0,
                                    max:
                                        100000000, // Set a reasonable maximum price
                                    value: agreedPrice,
                                    step: 10000, // Increment by 10k
                                    textAlign: TextAlign
                                        .center, // Center the value text
                                    iconSize:
                                        22, // Smaller icons for better alignment
                                    spacing:
                                        1, // Reduce spacing between elements
                                    decoration: const InputDecoration.collapsed(
                                      hintText: '',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        agreedPrice = value;
                                      });
                                    },
                                  ),
                                ),
                                // Warning messages
                                if (agreedPrice == 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '⚠️ This product will be free',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                else if (snapshot.hasData &&
                                    agreedPrice < product!.netPrice)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '⚠️ Price below net price',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (quantity <= 0) {
                            setState(() {
                              errorMessage = 'Enter valid quantity';
                            });
                            return;
                          }

                          // Check if quantity exceeds the total available stock (current stock + current quantity)
                          if (quantity > availableStock) {
                            setState(() {
                              errorMessage =
                                  'Maximum allowed quantity is $availableStock';
                            });
                            return;
                          }

                          transactionDetailBloc.add(
                            UpdateTransactionDetail(
                              transaction.transactionId,
                              detail.detailId,
                              {
                                'upc': upc, // We keep the original UPC
                                'quantity': quantity,
                                'agreed_price': agreedPrice,
                              },
                            ),
                          );
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Transaction detail updated successfully.')),
                          );
                        },
                        child: const Text('Update'),
                      ),
                    ],
                  );
                });
              }),
        );
      },
    );
  }

  void _showDeleteDetailConfirmation(
      BuildContext context, int transactionId, int detailId) {
    final transactionDetailBloc = context.read<TransactionDetailBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: transactionDetailBloc,
          child: AlertDialog(
            title: const Text('Delete Transaction Detail'),
            content: const Text(
                'Are you sure you want to delete this transaction detail?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  transactionDetailBloc.add(DeleteTransactionDetail(
                      transaction.transactionId, detailId));
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Transaction detail deleted successfully.')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Opens a bottom sheet with options to scan a barcode or search for a product.
  void _openAddProductOptions(BuildContext context, int transactionId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan Barcode'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _scanAndAddProduct(context, transactionId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Product'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _searchAndAddProduct(context, transactionId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Uses mobile_scanner to scan a product barcode and then adds it.
  Future<void> _scanAndAddProduct(
      BuildContext context, int transactionId) async {
    try {
      final barcode = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerPage(),
        ),
      );
      if (barcode == null || barcode.isEmpty) return;
      final productRepository =
          RepositoryProvider.of<ProductRepository>(context);
      final product = await productRepository.fetchProduct(barcode);
      // ignore: unnecessary_null_comparison
      if (product != null) {
        // Get current state to check if this product already exists in the transaction
        final transactionDetailBloc = context.read<TransactionDetailBloc>();
        final currentState = transactionDetailBloc.state;

        if (currentState is TransactionDetailLoaded) {
          // Check if this product already exists in the transaction details
          final existingDetail = currentState.details.firstWhere(
            (detail) => detail.upc == product.upc,
            orElse: () => TransactionDetail(
              detailId: -1,
              transactionId: transactionId,
              upc: '',
              quantity: 0,
              agreedPrice: 0,
            ),
          );
          if (existingDetail.detailId != -1) {
            // Product already exists in transaction, update quantity
            // Check if product is out of stock
            if (product.stock <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product is out of stock.')),
              );
              return;
            }

            // Increment quantity by 1 and update
            final newQuantity = existingDetail.quantity + 1;

            transactionDetailBloc.add(
              UpdateTransactionDetail(
                transactionId,
                existingDetail.detailId,
                {
                  'upc': product.upc,
                  'quantity': newQuantity,
                  'agreed_price': existingDetail.agreedPrice,
                },
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added 1 more ${product.name}')),
            );
            return;
          }
        } // Check if product is out of stock before adding
        if (product.stock <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product is out of stock.')),
          );
          return;
        }

        // Product is not already in the list, add it as a new item
        await _promptAddDetailDialog(context, product, transactionId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found')),
      );
      print('Product not found: $e');
    }
  }

  /// Opens a dialog to search for a product and then add it.
  Future<void> _searchAndAddProduct(
      BuildContext context, int transactionId) async {
    try {
      final productRepository =
          RepositoryProvider.of<ProductRepository>(context);
      final allProducts = await productRepository.fetchProducts();

      // Filter only active products and sort alphabetically
      final activeProducts = allProducts
          .where((product) => product.active == true)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final selectedProduct = await showDialog(
        context: context,
        builder: (dialogContext) {
          final TextEditingController searchController =
              TextEditingController();
          List<dynamic> filteredProducts = activeProducts;
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  width: double.maxFinite,
                  constraints:
                      const BoxConstraints(maxWidth: 500, maxHeight: 500),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      const Text(
                        'Search Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Search box with icon
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Enter product name',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.blue, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: (query) {
                            setState(() {
                              filteredProducts = activeProducts
                                  .where((p) => p.name
                                      .toLowerCase()
                                      .contains(query.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Product count
                      Text(
                        '${filteredProducts.length} products found',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Products list
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 36,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No products found',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return Card(
                                    elevation: 1,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      title: Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 3),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 1,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  'Display: Rp${_formatCurrency(product.displayPrice)}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.blue.shade800,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 1,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  'Net: Rp${_formatCurrency(product.netPrice)}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Colors.green.shade800,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(context, product);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Cancel button
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
      if (selectedProduct != null) {
        // Get current state to check if this product already exists in the transaction
        final transactionDetailBloc = context.read<TransactionDetailBloc>();
        final currentState = transactionDetailBloc.state;

        if (currentState is TransactionDetailLoaded) {
          // Check if this product already exists in the transaction details
          final existingDetail = currentState.details.firstWhere(
            (detail) => detail.upc == selectedProduct.upc,
            orElse: () => TransactionDetail(
              detailId: -1,
              transactionId: transactionId,
              upc: '',
              quantity: 0,
              agreedPrice: 0,
            ),
          );
          if (existingDetail.detailId != -1) {
            // Product already exists in transaction, update quantity
            // Check if product is out of stock
            if (selectedProduct.stock <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product is out of stock.')),
              );
              return;
            }

            // Increment quantity by 1 and update
            final newQuantity = existingDetail.quantity + 1;

            transactionDetailBloc.add(
              UpdateTransactionDetail(
                transactionId,
                existingDetail.detailId,
                {
                  'upc': selectedProduct.upc,
                  'quantity': newQuantity,
                  'agreed_price': existingDetail.agreedPrice,
                },
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added 1 more ${selectedProduct.name}')),
            );
            return;
          }
        }

        // Product is not already in the list, add it as a new item        // Check if product is out of stock before adding
        if (selectedProduct.stock <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product is out of stock.')),
          );
          return;
        }

        // Product is not already in the list, add it as a new item
        await _promptAddDetailDialog(context, selectedProduct, transactionId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: $e')),
      );
    }
  }

  /// Prompts the user to enter quantity and agreed price for the selected product.
  Future<void> _promptAddDetailDialog(
      BuildContext context, dynamic product, int transactionId) async {
    int quantity = 1; // Default quantity
    double agreedPrice = product.displayPrice; // Default price
    final transactionDetailBloc = context.read<TransactionDetailBloc>();
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: transactionDetailBloc,
          child: StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Center(
                child: Text(
                  'Add ${product.name}',
                  style: const TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: double.maxFinite,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Available stock: ${product.stock}',
                        style: TextStyle(
                          color: product.stock <= 0 ? Colors.red : Colors.black,
                          fontWeight: product.stock <= 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text('Net price: Rp${_formatCurrency(product.netPrice)}'),
                      if (product.stock <= 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Warning: This product is out of stock!',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Quantity SpinBox
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quantity:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 36, // Height for better tap target
                            alignment:
                                Alignment.center, // Center content vertically
                            child: SpinBox(
                              min: 1,
                              max: product.stock.toDouble(),
                              value: quantity.toDouble(),
                              decimals: 0,
                              step: 1,
                              textAlign:
                                  TextAlign.center, // Center the value text
                              iconSize:
                                  22, // Smaller icons for better alignment
                              spacing: 1, // Reduce spacing between elements
                              decoration: const InputDecoration.collapsed(
                                hintText: '',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  quantity = value.toInt();
                                  if (errorMessage != null) {
                                    errorMessage = null;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Agreed Price SpinBox
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agreed Price (Rp):',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 36, // Height for better tap target
                            alignment:
                                Alignment.center, // Center content vertically
                            child: SpinBox(
                              min: 0,
                              max: 100000000, // Set a reasonable maximum price
                              value: agreedPrice,
                              step: 10000, // Increment by 10k
                              textAlign:
                                  TextAlign.center, // Center the value text
                              iconSize:
                                  22, // Smaller icons for better alignment
                              spacing: 1, // Reduce spacing between elements
                              decoration: const InputDecoration.collapsed(
                                hintText: '',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  agreedPrice = value;
                                });
                              },
                            ),
                          ),
                          // Warning messages
                          if (agreedPrice == 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '⚠️ This product will be free',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else if (agreedPrice < product.netPrice)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '⚠️ Price below net price',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: product.stock <= 0
                            ? null
                            : () {
                                if (quantity <= 0) {
                                  setState(() {
                                    errorMessage = 'Enter valid quantity';
                                  });
                                  return;
                                }
                                if (quantity > product.stock) {
                                  setState(() {
                                    errorMessage = 'Quantity exceeds stock';
                                  });
                                  return;
                                }
                                transactionDetailBloc.add(
                                  AddTransactionDetail(
                                    transactionId,
                                    {
                                      'upc': product.upc,
                                      'quantity': quantity,
                                      'agreed_price': agreedPrice,
                                    },
                                  ),
                                );
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Transaction detail added successfully')),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = transaction.dateCreated.toLocal().toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: Text(dateStr),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Invoice',
            onPressed: () {
              final state = context.read<TransactionDetailBloc>().state;
              if (state is TransactionDetailLoaded) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InvoicePrintPreviewPage(
                      transaction: state.transaction,
                      details: state.details,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice not available yet.')),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionDetailBloc, TransactionDetailState>(
        builder: (context, state) {
          if (state is TransactionDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionDetailLoaded) {
            final updatedTransaction = state.transaction;
            final details = state.details;
            return Container(
              color: Colors.grey.shade50,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: Colors.blue.shade600,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transaction Summary',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            _buildTransactionInfoRow(
                              label: 'Display Price',
                              value:
                                  'Rp${_formatCurrency(updatedTransaction.totalDisplayPrice)}',
                            ),
                            _buildTransactionInfoRow(
                              label: 'Agreed Price',
                              value:
                                  'Rp${_formatCurrency(updatedTransaction.totalAgreedPrice)}',
                            ),
                            _buildTransactionInfoRow(
                              label: 'Net Price',
                              value:
                                  'Rp${_formatCurrency(updatedTransaction.totalNetPrice)}',
                            ),
                            _buildTransactionInfoRow(
                              label: 'Quantity',
                              value: updatedTransaction.quantity.toString(),
                            ),
                            _buildTransactionInfoRow(
                              label: 'Date Created',
                              value: updatedTransaction.dateCreated
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                            ),
                            _buildTransactionInfoRow(
                              label: 'Last Updated',
                              value: updatedTransaction.lastUpdated
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                            ),
                            _buildTransactionInfoRow(
                              label: 'User ID',
                              value: state.user.userId.toString(),
                            ),
                            _buildTransactionInfoRow(
                              label: 'Username',
                              value: state.user.username,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (updatedTransaction.note != null &&
                        updatedTransaction.note!.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                updatedTransaction.note!,
                                style: const TextStyle(fontSize: 15.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16.0),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        'Product List',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _buildTransactionDetailsList(
                        context, details, updatedTransaction.transactionId),
                    // Add padding at the bottom to ensure FAB doesn't cover content
                    const SizedBox(height: 80.0),
                  ],
                ),
              ),
            );
          } else if (state is TransactionDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionDetailBloc>().add(
                          FetchTransactionDetails(transaction.transactionId));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Unknown state.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _openAddProductOptions(context, transaction.transactionId),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A dedicated page for scanning barcodes using mobile_scanner.
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        // Stop scanning to prevent further detections.
        _controller.stop();
        Navigator.of(context).pop(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}
