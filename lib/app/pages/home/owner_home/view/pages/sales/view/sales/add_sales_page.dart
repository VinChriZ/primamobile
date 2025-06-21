import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'package:primamobile/utils/globals.dart';

/// A model representing a product added to the sales transaction.
class SalesProductItem {
  final Product product;
  final int quantity;
  final double agreedPrice;

  SalesProductItem({
    required this.product,
    required this.quantity,
    required this.agreedPrice,
  });

  @override
  String toString() {
    return 'SalesProductItem(product: ${product.name}, quantity: $quantity, agreedPrice: $agreedPrice)';
  }
}

/// Page to add a new sales transaction.
class AddSalesPage extends StatefulWidget {
  const AddSalesPage({super.key});

  // Static variable to store the last selected date
  static DateTime? lastSelectedDate;

  @override
  State<AddSalesPage> createState() => _AddSalesPageState();
}

class _AddSalesPageState extends State<AddSalesPage> {
  final _formKey = GlobalKey<FormState>();

  // Transaction fields
  // Use the lastSelectedDate if available, otherwise use the current date
  late DateTime _transactionDate;
  final TextEditingController _notesController = TextEditingController();

  // List to store products added to the sale.
  final List<SalesProductItem> _salesItems = [];

  // Get the total quantity of all items
  int get _totalQuantity {
    return _salesItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  // Get running total of agreed price.
  double get _totalAgreedPrice {
    return _salesItems.fold(
      0.0,
      (sum, item) => sum + (item.agreedPrice * item.quantity),
    );
  }

  late final TransactionRepository _transactionRepository;
  late final TransactionDetailRepository _transactionDetailRepository;
  late final ProductRepository _productRepository;

  @override
  void initState() {
    super.initState();
    _transactionDate = AddSalesPage.lastSelectedDate ?? DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get repositories from the context.
    _transactionRepository =
        RepositoryProvider.of<TransactionRepository>(context);
    _transactionDetailRepository =
        RepositoryProvider.of<TransactionDetailRepository>(context);
    _productRepository = RepositoryProvider.of<ProductRepository>(context);
  }

  // Add currency formatting helper
  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  /// Called when the user wants to add a product.
  void _openAddProductOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan Barcode'),
                onTap: () async {
                  Navigator.pop(context);
                  await _scanAndAddProduct();
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search Product'),
                onTap: () async {
                  Navigator.pop(context);
                  await _searchAndAddProduct();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Scan barcode using mobile_scanner.
  Future<void> _scanAndAddProduct() async {
    try {
      // Navigate to the scanner page and wait for a barcode result.
      final barcode = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
      );

      if (barcode == null || barcode.isEmpty) {
        // User cancelled scanning or no barcode detected.
        return;
      }
      // Fetch the product using the scanned barcode.
      final product = await _productRepository.fetchProduct(barcode);
      // ignore: unnecessary_null_comparison
      if (product != null) {
        // Check if this product is already in the list
        final existingItemIndex = _salesItems.indexWhere((item) =>
            item.product.upc ==
            product.upc); // Check if product is out of stock
        if (product.stock <= 0) {
          _showError('Product is out of stock.');
          return;
        }

        if (existingItemIndex != -1) {
          // Product already exists in the list, update its quantity
          final existingItem = _salesItems[existingItemIndex];

          // Make sure we don't exceed stock limits
          if (existingItem.quantity >= product.stock) {
            _showError('Cannot add more items. Maximum stock reached.');
            return;
          }

          // Increment quantity by 1 (or show dialog to choose quantity)
          _editSalesItem(existingItemIndex, incrementQuantity: true);
        } else {
          // Product is not in the list, add it as a new item
          await _promptAddProductDetail(product);
        }
      } else {
        _showError('Product not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found')),
      );
      print('Product not found: $e');
    }
  }

  /// Search for a product using a search dialog.
  Future<void> _searchAndAddProduct() async {
    try {
      final allProducts = await _productRepository.fetchProducts();
      final selectedProduct = await showDialog<Product?>(
        context: context,
        builder: (context) {
          final TextEditingController searchController =
              TextEditingController();
          List<Product> filteredProducts = allProducts;
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
                              filteredProducts = allProducts
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
        // Check if product is out of stock
        if (selectedProduct.stock <= 0) {
          _showError('Product is out of stock.');
          return;
        }

        // Check if this product is already in the list
        final existingItemIndex = _salesItems
            .indexWhere((item) => item.product.upc == selectedProduct.upc);

        if (existingItemIndex != -1) {
          // Product already exists in the list, update its quantity
          final existingItem = _salesItems[existingItemIndex];

          // Make sure we don't exceed stock limits
          if (existingItem.quantity >= selectedProduct.stock) {
            _showError('Cannot add more items. Maximum stock reached.');
            return;
          }

          // Increment quantity by 1
          _editSalesItem(existingItemIndex, incrementQuantity: true);
        } else {
          // Product is not in the list, add it as a new item
          await _promptAddProductDetail(selectedProduct);
        }
      }
    } catch (e) {
      _showError('Error searching products: $e');
    }
  }

  /// Prompt the user to enter quantity and agreed price for the selected product.
  Future<void> _promptAddProductDetail(Product product) async {
    int quantity = 1; // Default quantity
    double agreedPrice = product.displayPrice; // Default price
    String? errorMessage;

    final result = await showDialog<SalesProductItem>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
                    Text('Available stock: ${product.stock}'),
                    Text('Net price: Rp${_formatCurrency(product.netPrice)}'),
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
                            iconSize: 22, // Smaller icons for better alignment
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
                            step: 10000, // Increment by 10k as requested
                            textAlign:
                                TextAlign.center, // Center the value text
                            iconSize: 22, // Smaller icons for better alignment
                            spacing: 1, // Reduce spacing between elements
                            decoration: const InputDecoration.collapsed(
                              hintText: '',
                            ),
                            onChanged: (value) {
                              setState(() {
                                agreedPrice = value;
                                if (errorMessage != null) {
                                  errorMessage = null;
                                }
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
                        else if (agreedPrice < product.netPrice)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
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
                        Navigator.pop(
                          context,
                          SalesProductItem(
                            product: product,
                            quantity: quantity,
                            agreedPrice: agreedPrice,
                          ),
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
        });
      },
    );
    if (result != null) {
      setState(() {
        _salesItems.add(result);
      });
    }
  }

  /// Edit an existing sales item
  void _editSalesItem(int index, {bool incrementQuantity = false}) async {
    final item = _salesItems[index];
    int quantity = item.quantity;
    if (incrementQuantity && quantity < item.product.stock) {
      // Automatically increment quantity by 1 if requested
      quantity += 1;
      // Immediately update the item
      setState(() {
        _salesItems[index] = SalesProductItem(
          product: item.product,
          quantity: quantity,
          agreedPrice: item.agreedPrice,
        );
      });
      // Show a brief notification that the item was added
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added 1 more ${item.product.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
      return; // Skip opening dialog for quick add
    }
    double agreedPrice = item.agreedPrice;
    String? errorMessage;
    final result = await showDialog<SalesProductItem>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
            title: Center(
              child: Text(
                'Edit ${item.product.name}',
                style: const TextStyle(fontSize: 14),
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
                    Text('Available stock: ${item.product.stock}'),
                    Text(
                        'Net price: Rp${_formatCurrency(item.product.netPrice)}'),
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
                            max: item.product.stock.toDouble(),
                            value: quantity.toDouble(),
                            decimals: 0,
                            step: 1,
                            textAlign:
                                TextAlign.center, // Center the value text
                            iconSize: 20, // Smaller icons for better alignment
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
                            step: 10000, // Increment by 25k as requested
                            textAlign:
                                TextAlign.center, // Center the value text
                            iconSize: 20, // Smaller icons for better alignment
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
                        else if (agreedPrice < item.product.netPrice)
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
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
                        if (quantity <= 0) {
                          setState(() {
                            errorMessage = 'Enter valid quantity';
                          });
                          return;
                        }
                        if (agreedPrice <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter valid price')),
                          );
                          return;
                        }
                        if (quantity > item.product.stock) {
                          setState(() {
                            errorMessage = 'Quantity exceeds stock';
                          });
                          return;
                        }
                        Navigator.pop(
                          context,
                          SalesProductItem(
                            product: item.product,
                            quantity: quantity,
                            agreedPrice: agreedPrice,
                          ),
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
                        'Update',
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
        });
      },
    );

    if (result != null) {
      setState(() {
        _salesItems[index] = result;
      });
    }
  }

  /// Remove an item from the list.
  void _removeSalesItem(int index) {
    setState(() {
      _salesItems.removeAt(index);
    });
  }

  /// Submit the transaction along with its details.
  Future<void> _submitTransaction() async {
    if (_salesItems.isEmpty) {
      _showError('Please add at least one product');
      return;
    }
    try {
      final transactionPayload = {
        'date_created': _transactionDate.toIso8601String(),
        'note': _notesController.text,
        'user_id': Globals.userSession.user.userId,
      };
      final transaction = await _transactionRepository.addTransaction(
        transactionPayload,
      );

      for (var item in _salesItems) {
        final detailPayload = {
          'upc': item.product.upc,
          'quantity': item.quantity,
          'agreed_price': item.agreedPrice,
        };
        await _transactionDetailRepository.addTransactionDetail(
            transaction.transactionId, detailPayload);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Failed to submit transaction: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final String dateStr = DateFormat('yyyy-MM-dd').format(_transactionDate);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sale', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transaction Date Card - Blue outline
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade400, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withAlpha(100),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.blue.shade700,
                      size: 18,
                    ),
                  ),
                  title: const Text(
                    'Transaction Date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue.shade700,
                        size: 16,
                      ),
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _transactionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.blue.shade700,
                              ),
                              dialogTheme: const DialogTheme(
                                backgroundColor: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _transactionDate = picked;
                          AddSalesPage.lastSelectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ),

              // Notes Field - Yellow outline
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.shade100.withAlpha(100),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(
                            Icons.note_alt,
                            color: Colors.amber.shade700,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Notes (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about this sale...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              // Products Section with green outline for entire container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade400, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade100.withAlpha(100),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Products Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.shopping_cart,
                                color: Colors.green.shade700,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Products',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_salesItems.length} items',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // List of Added Products or centered text if empty
                    _salesItems.isEmpty
                        ? SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 36,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No products added yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap the + button to add products',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _salesItems.length,
                            itemBuilder: (context, index) {
                              final item = _salesItems[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.grey.shade300.withAlpha(100),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Qty: ${item.quantity}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Agreed Price',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                'Rp${_formatCurrency(item.agreedPrice)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Rp${_formatCurrency(item.agreedPrice * item.quantity)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _editSalesItem(index),
                                              icon: Icon(
                                                Icons.edit,
                                                size: 12,
                                                color: Colors.blue.shade700,
                                              ),
                                              label: Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color:
                                                        Colors.blue.shade200),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                minimumSize: const Size(0, 28),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _removeSalesItem(index),
                                              icon: Icon(
                                                Icons.delete_outline,
                                                size: 12,
                                                color: Colors.red.shade700,
                                              ),
                                              label: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red.shade700,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    color: Colors.red.shade200),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                minimumSize: const Size(0, 28),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Total Section
              if (_salesItems.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withAlpha(100),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Quantity:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _totalQuantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Rp${_formatCurrency(_totalAgreedPrice)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Submit Button
              ElevatedButton.icon(
                onPressed: _salesItems.isEmpty ? null : _submitTransaction,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label:
                    const Text('Submit Sale', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),

              // Extra space at bottom for FAB
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProductOptions,
        backgroundColor: Colors.blue.shade700,
        elevation: 3,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A dedicated page for scanning barcodes using the mobile_scanner package.
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
        // Stop further detection before popping.
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
