import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/sales/sales_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/sales/sales_edit.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/transaction_detail_page.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  void _navigateToDetail(BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(transaction: transaction),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Transaction transaction) async {
    final updatedTransaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesEdit(transaction: transaction),
      ),
    );
    if (updatedTransaction != null) {
      context.read<SalesBloc>().add(const FetchSales());
    }
  }

  void _showDeleteConfirmation(BuildContext context, int transactionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SalesBloc>().add(DeleteTransaction(transactionId));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Transaction deleted successfully.')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Builds the card UI exactly as you designed it.
  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
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
        onTap: () => _navigateToDetail(context, transaction),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Created as the title.
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
              // Row with Edit and Delete buttons.
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () => _navigateToEdit(context, transaction),
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
                      onPressed: () => _showDeleteConfirmation(
                          context, transaction.transactionId),
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

  /// Helper method to build a row for each attribute.
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
          // Horizontally scrollable row of dropdown filters.
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                _DateRangeDropdown(),
                SizedBox(width: 16.0),
                _SortByDropdown(),
                SizedBox(width: 16.0),
                _SortOrderDropdown(),
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
                      context.read<SalesBloc>().add(const FetchSales());
                    },
                    child: ListView.builder(
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        return _buildTransactionCard(context, transaction);
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
        onPressed: () {
          // Placeholder for adding new transactions.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Add Transaction functionality not implemented yet.'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Dropdown for selecting a date range.
class _DateRangeDropdown extends StatefulWidget {
  const _DateRangeDropdown();

  @override
  _DateRangeDropdownState createState() => _DateRangeDropdownState();
}

class _DateRangeDropdownState extends State<_DateRangeDropdown> {
  String? _selectedDateRange = 'Last 7 Days';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _applyPreset('Last 7 Days');
  }

  void _applyPreset(String preset) {
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
      } else {
        _startDate = null;
        _endDate = null;
      }
    });
    _applyFilters();
  }

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

  void _applyFilters() {
    context.read<SalesBloc>().add(
          FetchSales(startDate: _startDate, endDate: _endDate),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Date Range',
          border: OutlineInputBorder(),
        ),
        value: _selectedDateRange,
        items: <String>['Last 7 Days', 'Last Month', 'Last Year', 'Custom']
            .map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          if (value == 'Custom') {
            _selectCustomRange();
          } else if (value != null) {
            _applyPreset(value);
          }
        },
      ),
    );
  }
}

/// Dropdown for selecting the sort field.
class _SortByDropdown extends StatefulWidget {
  const _SortByDropdown();

  @override
  _SortByDropdownState createState() => _SortByDropdownState();
}

class _SortByDropdownState extends State<_SortByDropdown> {
  String? _selectedSortBy = 'Last Updated';

  void _applySortBy(String sortBy) {
    setState(() {
      _selectedSortBy = sortBy;
    });
    context.read<SalesBloc>().add(
          FetchSales(sortBy: _mapSortBy(sortBy)),
        );
  }

  String _mapSortBy(String sortBy) {
    if (sortBy == 'Last Updated') return 'last_updated';
    if (sortBy == 'Stock') return 'quantity';
    if (sortBy == 'Profit') return 'profit';
    return sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Sort By',
          border: OutlineInputBorder(),
        ),
        value: _selectedSortBy,
        items: <String>['Last Updated', 'Stock', 'Profit'].map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _applySortBy(value);
          }
        },
      ),
    );
  }
}

/// Dropdown for selecting the sort order.
class _SortOrderDropdown extends StatefulWidget {
  const _SortOrderDropdown();

  @override
  _SortOrderDropdownState createState() => _SortOrderDropdownState();
}

class _SortOrderDropdownState extends State<_SortOrderDropdown> {
  String _selectedSortOrder = 'Ascending';

  void _applySortOrder(String order) {
    setState(() {
      _selectedSortOrder = order;
    });
    context.read<SalesBloc>().add(
          FetchSales(
              sortOrder: order.toLowerCase() == 'ascending' ? 'asc' : 'desc'),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            _applySortOrder(value);
          }
        },
      ),
    );
  }
}
