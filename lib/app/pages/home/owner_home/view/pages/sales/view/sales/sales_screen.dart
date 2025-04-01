import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/sales/sales_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/sales/add_sales_page.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/sales/sales_edit.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/transaction_detail_page.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  /// Handles date range changes. Based on the selected value,
  /// determines the appropriate start/end dates and dispatches a FetchSales event.
  Future<void> _handleDateRangeChange(
      BuildContext context, String? value, SalesState state) async {
    String selectedDateRange = value ?? 'All Dates';
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    if (selectedDateRange == 'Last 7 Days') {
      startDate = now.subtract(const Duration(days: 7));
      endDate = now;
    } else if (selectedDateRange == 'Last Month') {
      startDate = DateTime(now.year, now.month - 1, now.day);
      endDate = now;
    } else if (selectedDateRange == 'Last Year') {
      startDate = DateTime(now.year - 1, now.month, now.day);
      endDate = now;
    } else if (selectedDateRange == 'Custom') {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: now,
      );
      if (picked != null) {
        startDate = picked.start;
        endDate = picked.end;
        selectedDateRange = 'Custom';
      } else {
        // If the user cancels, use the current state's values.
        if (state is SalesLoaded) {
          selectedDateRange = state.selectedDateRange;
          startDate = state.startDate;
          endDate = state.endDate;
        }
      }
    } else {
      // "All Dates"
      startDate = null;
      endDate = null;
    }

    // Use current sort filters from state, or default values.
    String sortBy =
        (state is SalesLoaded) ? state.selectedSortBy : 'date_created';
    String sortOrder =
        (state is SalesLoaded) ? state.selectedSortOrder : 'desc';

    context.read<SalesBloc>().add(
          FetchSales(
            selectedDateRange: selectedDateRange,
            startDate: startDate,
            endDate: endDate,
            sortBy: sortBy,
            sortOrder: sortOrder,
          ),
        );
  }

  /// Helper widget to build a card with consistent styling across the app.
  Widget _buildCard({
    required Widget child,
    Color? color,
    String? title,
    IconData? titleIcon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: color ?? Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    if (titleIcon != null) ...[
                      Icon(
                        titleIcon,
                        size: 18, // Decreased from 20
                        color: Colors.blue[800],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16, // Decreased from 18
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Decreased from 12
                Divider(color: Colors.blue.shade300, thickness: 1),
                const SizedBox(height: 6), // Decreased from 8
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }

  /// Format currency values with a thousands separator
  String formatCurrency(double value) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    return 'Rp. ${formatter.format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<SalesBloc, SalesState>(
          builder: (context, state) {
            // Provide defaults if the state is not yet SalesLoaded.
            final selectedDateRange =
                (state is SalesLoaded) ? state.selectedDateRange : 'All Dates';
            final selectedSortBy =
                (state is SalesLoaded) ? state.selectedSortBy : 'date_created';
            final selectedSortOrder =
                (state is SalesLoaded) ? state.selectedSortOrder : 'desc';

            return Column(
              children: [
                // Remove the title bar and just keep the filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
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
                          value: selectedDateRange,
                          items: const [
                            DropdownMenuItem(
                                value: 'Last 7 Days',
                                child: Text('Last 7 Days')),
                            DropdownMenuItem(
                                value: 'Last Month', child: Text('Last Month')),
                            DropdownMenuItem(
                                value: 'Last Year', child: Text('Last Year')),
                            DropdownMenuItem(
                                value: 'All Dates', child: Text('All Dates')),
                            DropdownMenuItem(
                                value: 'Custom', child: Text('Custom')),
                          ],
                          onChanged: (value) =>
                              _handleDateRangeChange(context, value, state),
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
                          value: selectedSortBy,
                          items: const [
                            DropdownMenuItem(
                                value: 'last_updated',
                                child: Text('Last Updated')),
                            DropdownMenuItem(
                                value: 'quantity', child: Text('Stock')),
                            DropdownMenuItem(
                                value: 'profit', child: Text('Profit')),
                            DropdownMenuItem(
                                value: 'date_created',
                                child: Text('Date Created')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<SalesBloc>().add(
                                    FetchSales(
                                      selectedDateRange: selectedDateRange,
                                      startDate: (state is SalesLoaded)
                                          ? state.startDate
                                          : null,
                                      endDate: (state is SalesLoaded)
                                          ? state.endDate
                                          : null,
                                      sortBy: value,
                                      sortOrder: selectedSortOrder,
                                    ),
                                  );
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
                          // Display as "Ascending" or "Descending" based on stored value.
                          value: selectedSortOrder.toLowerCase() == 'asc'
                              ? 'Ascending'
                              : 'Descending',
                          items: const [
                            DropdownMenuItem(
                                value: 'Ascending', child: Text('Ascending')),
                            DropdownMenuItem(
                                value: 'Descending', child: Text('Descending')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              String sortOrder =
                                  value.toLowerCase() == 'ascending'
                                      ? 'asc'
                                      : 'desc';
                              context.read<SalesBloc>().add(
                                    FetchSales(
                                      selectedDateRange: selectedDateRange,
                                      startDate: (state is SalesLoaded)
                                          ? state.startDate
                                          : null,
                                      endDate: (state is SalesLoaded)
                                          ? state.endDate
                                          : null,
                                      sortBy: selectedSortBy,
                                      sortOrder: sortOrder,
                                    ),
                                  );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Transaction List
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state is SalesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SalesLoaded) {
                        if (state.transactions.isEmpty) {
                          return const Center(
                              child: Text('No transactions available.'));
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<SalesBloc>().add(
                                  FetchSales(
                                    selectedDateRange: state.selectedDateRange,
                                    startDate: state.startDate,
                                    endDate: state.endDate,
                                    sortBy: state.selectedSortBy,
                                    sortOrder: state.selectedSortOrder,
                                  ),
                                );
                          },
                          child: ListView.builder(
                            itemCount: state.transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = state.transactions[index];
                              final dateString = DateFormat('yyyy-MM-dd')
                                  .format(transaction.dateCreated);

                              // Calculate profit
                              final profit = transaction.totalAgreedPrice -
                                  transaction.totalNetPrice;

                              return InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailPage(
                                              transaction: transaction),
                                    ),
                                  );
                                  context.read<SalesBloc>().add(
                                        FetchSales(
                                          selectedDateRange:
                                              state.selectedDateRange,
                                          startDate: state.startDate,
                                          endDate: state.endDate,
                                          sortBy: state.selectedSortBy,
                                          sortOrder: state.selectedSortOrder,
                                        ),
                                      );
                                },
                                child: _buildCard(
                                  title: 'Transaction: $dateString',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildAttributeRow(
                                        "Profit",
                                        formatCurrency(profit),
                                      ),
                                      const SizedBox(height: 6.0),
                                      _buildAttributeRow("Quantity",
                                          transaction.quantity.toString()),
                                      const SizedBox(height: 6.0),
                                      _buildAttributeRow(
                                          "Last Updated",
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .format(transaction.lastUpdated)),
                                      const SizedBox(height: 12.0),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical:
                                                        10.0), // Reduced padding
                                              ),
                                              onPressed: () async {
                                                final updated =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SalesEdit(
                                                            transaction:
                                                                transaction),
                                                  ),
                                                );
                                                if (updated != null) {
                                                  context.read<SalesBloc>().add(
                                                        FetchSales(
                                                          selectedDateRange: state
                                                              .selectedDateRange,
                                                          startDate:
                                                              state.startDate,
                                                          endDate:
                                                              state.endDate,
                                                          sortBy: state
                                                              .selectedSortBy,
                                                          sortOrder: state
                                                              .selectedSortOrder,
                                                        ),
                                                      );
                                                }
                                              },
                                              child: const Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize:
                                                      14, // Reduced from 16
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical:
                                                        10.0), // Reduced padding
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Delete Transaction'),
                                                      content: const Text(
                                                          'Are you sure you want to delete this transaction?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  dialogContext),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            context
                                                                .read<
                                                                    SalesBloc>()
                                                                .add(DeleteTransaction(
                                                                    transaction
                                                                        .transactionId));
                                                            Navigator.pop(
                                                                dialogContext);
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Transaction deleted successfully.')),
                                                            );
                                                          },
                                                          child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  fontSize:
                                                      14, // Reduced from 16
                                                  fontWeight: FontWeight.bold,
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
                        );
                      } else if (state is SalesError) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 300,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 48, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error: ${state.message}',
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Sale"),
        backgroundColor: Colors.blue[700],
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSalesPage()),
          );
          if (result == true) {
            final currentState = context.read<SalesBloc>().state;
            if (currentState is SalesLoaded) {
              context.read<SalesBloc>().add(
                    FetchSales(
                      selectedDateRange: currentState.selectedDateRange,
                      startDate: currentState.startDate,
                      endDate: currentState.endDate,
                      sortBy: currentState.selectedSortBy,
                      sortOrder: currentState.selectedSortOrder,
                    ),
                  );
            }
          }
        },
      ),
    );
  }

  /// Helper widget to build a row for a given label/value pair.
  Widget _buildAttributeRow(String label, String value) {
    // Extract the base label without the colon
    String baseLabel =
        label.endsWith(':') ? label.substring(0, label.length - 1) : label;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150, // Increased width from 110 to 130
          padding: const EdgeInsets.only(right: 5),
          child: Text(
            baseLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14, // Decreased from 16
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 5), // Space before colon
        const Text(
          ":",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14, // Decreased from 16
          ),
        ),
        const SizedBox(width: 10), // Space after colon
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14), // Decreased from 16
          ),
        ),
      ],
    );
  }
}
