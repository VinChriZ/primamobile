import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/sales/sales_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/sales/add_sales_page.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/sales/sales_edit.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/transaction_detail_page.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // Filter state variables
  String _selectedDateRange = 'All Dates'; // Default
  DateTime? _startDate;
  DateTime? _endDate;

  // For sorting
  String _selectedSortBy = 'Date Created'; // Default
  String _selectedSortOrder = 'Descending'; // Default

  @override
  void initState() {
    super.initState();
    _applyDatePreset(_selectedDateRange);
  }

  // Updates date filters based on preset
  void _applyDatePreset(String preset) {
    final now = DateTime.now();
    setState(() {
      _selectedDateRange = preset;
      if (preset == 'Last 7 Days') {
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
      } else if (preset == 'Last Month') {
        _startDate = DateTime(now.year, now.month - 1, now.day);
        _endDate = now;
      } else if (preset == 'Last Year') {
        _startDate = DateTime(now.year - 1, now.month, now.day);
        _endDate = now;
      } else if (preset == 'All Dates') {
        _startDate = null;
        _endDate = null;
      }
    });
    _applyFilters();
  }

  // Callback for custom date range selection
  Future<void> _selectCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = 'Custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  // Map the display sort field to the backend field name
  String _mapSortBy(String sortBy) {
    if (sortBy == 'Last Updated') return 'last_updated';
    if (sortBy == 'Stock') return 'quantity';
    if (sortBy == 'Profit') return 'profit';
    if (sortBy == 'Date Created') return 'date_created';
    return sortBy;
  }

  // Dispatch the FetchSales event with all current filters.
  void _applyFilters() {
    context.read<SalesBloc>().add(
          FetchSales(
            startDate: _startDate,
            endDate: _endDate,
            sortBy: _mapSortBy(_selectedSortBy),
            sortOrder: _selectedSortOrder.toLowerCase() == 'ascending'
                ? 'asc'
                : 'desc',
          ),
        );
  }

  void _navigateToDetail(Transaction transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(transaction: transaction),
      ),
    );
    _applyFilters();
  }

  void _navigateToEdit(Transaction transaction) async {
    final updatedTransaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesEdit(transaction: transaction),
      ),
    );
    if (updatedTransaction != null) {
      _applyFilters();
    }
  }

  void _showDeleteConfirmation(int transactionId) {
    // Capture the SalesBloc from the parent context
    final salesBloc = context.read<SalesBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                salesBloc.add(DeleteTransaction(transactionId));
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction deleted successfully.'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    double profit = transaction.totalAgreedPrice - transaction.totalNetPrice;
    String dateCreatedStr =
        DateFormat('yyyy-MM-dd').format(transaction.dateCreated);
    String lastUpdatedStr =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.lastUpdated);

    return Card(
      color: Colors.lightBlue[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateCreatedStr,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              _buildAttributeRow("Profit:", "Rp${profit.toStringAsFixed(0)}"),
              const SizedBox(height: 6.0),
              _buildAttributeRow("Quantity:", transaction.quantity.toString()),
              const SizedBox(height: 6.0),
              _buildAttributeRow("Last Updated:", lastUpdatedStr),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () => _navigateToEdit(transaction),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () =>
                          _showDeleteConfirmation(transaction.transactionId),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildAttributeRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 180,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: Column(
        children: [
          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                // Date Range Dropdown
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Date Range',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedDateRange,
                    items: <String>[
                      'Last 7 Days',
                      'Last Month',
                      'Last Year',
                      'All Dates',
                      'Custom'
                    ].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        if (value == 'Custom') {
                          _selectCustomRange();
                        } else {
                          _applyDatePreset(value);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                // Sort By Dropdown
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSortBy,
                    items: <String>[
                      'Last Updated',
                      'Stock',
                      'Profit',
                      'Date Created'
                    ].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSortBy = value;
                        });
                        _applyFilters();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                // Sort Order Dropdown
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Sort Order',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSortOrder,
                    items: <String>['Ascending', 'Descending'].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSortOrder = value;
                        });
                        _applyFilters();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Transaction List
          Expanded(
            child: BlocBuilder<SalesBloc, SalesState>(
              builder: (context, state) {
                if (state is SalesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SalesLoaded) {
                  if (state.transactions.isEmpty) {
                    return const Center(
                        child: Text('No transactions available.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      _applyFilters();
                    },
                    child: ListView.builder(
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
                  );
                } else if (state is SalesError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSalesPage()),
          );
          if (result == true) {
            _applyFilters();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
