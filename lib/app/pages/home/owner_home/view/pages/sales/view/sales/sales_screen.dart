import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/sales/sales_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/sales/add_sales_page.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/sales/sales_edit.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/transaction_detail_page.dart';
import 'package:primamobile/utils/globals.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  /// Handles date range changes
  Future<void> _handleDateRangeChange(
      BuildContext context, String? value, SalesState state) async {
    String selectedDateRange = value ?? 'Last 7 Days';
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
    } else if (selectedDateRange == 'All Dates') {
      // set start and end dates to null
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

  /// widget to build a card
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
                        size: 18,
                        color: Colors.blue[800],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.blue.shade300, thickness: 1),
                const SizedBox(height: 6),
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
            // Provide defaults value if the state is not yet SalesLoaded.
            final selectedDateRange = (state is SalesLoaded)
                ? state.selectedDateRange
                : 'Last 7 Days';
            final selectedSortBy =
                (state is SalesLoaded) ? state.selectedSortBy : 'date_created';
            final selectedSortOrder =
                (state is SalesLoaded) ? state.selectedSortOrder : 'desc';
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Date Range Dropdown
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Date Range',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            labelStyle: TextStyle(fontSize: 12),
                          ),
                          value: selectedDateRange,
                          items: const [
                            DropdownMenuItem(
                                value: 'Last 7 Days',
                                child: Text('Last 7 Days',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'Last Month',
                                child: Text('Last Month',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'Last Year',
                                child: Text('Last Year',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'All Dates',
                                child: Text('All Dates',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'Custom',
                                child: Text('Custom',
                                    style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (value) =>
                              _handleDateRangeChange(context, value, state),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      // Sort By Dropdown
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Sort By',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            labelStyle: TextStyle(fontSize: 12),
                          ),
                          value: selectedSortBy,
                          items: const [
                            DropdownMenuItem(
                                value: 'last_updated',
                                child: Text('Last Updated',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'quantity',
                                child: Text('Quantity',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'profit',
                                child: Text('Profit',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'date_created',
                                child: Text('Date Created',
                                    style: TextStyle(fontSize: 13))),
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
                      const SizedBox(width: 10.0),
                      // Sort Order Dropdown
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Sort Order',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8.0),
                            labelStyle: TextStyle(fontSize: 12),
                          ),
                          // Display as "Ascending" or "Descending" based on stored value.
                          value: selectedSortOrder.toLowerCase() == 'asc'
                              ? 'Ascending'
                              : 'Descending',
                          items: const [
                            DropdownMenuItem(
                                value: 'Ascending',
                                child: Text('Ascending',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'Descending',
                                child: Text('Descending',
                                    style: TextStyle(fontSize: 13))),
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
                                      // Only show profit if user role is 1 or 2
                                      if (Globals.userSession.user.roleId ==
                                              1 ||
                                          Globals.userSession.user.roleId ==
                                              2) ...[
                                        _buildAttributeRow(
                                          "Profit",
                                          formatCurrency(profit),
                                        ),
                                        const SizedBox(height: 6.0),
                                      ],
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
                                            child: SizedBox(
                                              height: 34,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue[600],
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
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
                                                    context
                                                        .read<SalesBloc>()
                                                        .add(
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
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          // Only show Delete button if user role is 1 or 2
                                          if (Globals.userSession.user.roleId ==
                                                  1 ||
                                              Globals.userSession.user.roleId ==
                                                  2)
                                            Expanded(
                                              child: SizedBox(
                                                height: 34,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red[400],
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
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
                                                                ScaffoldMessenger.of(
                                                                        context)
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
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
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
                                  const Icon(Icons.error_outline,
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
        icon: const Icon(Icons.add, size: 20),
        label: const Text("Add Sale", style: TextStyle(fontSize: 13)),
        backgroundColor: Colors.blue[700],
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  /// widget to build a row
  Widget _buildAttributeRow(String label, String value) {
    String baseLabel =
        label.endsWith(':') ? label.substring(0, label.length - 1) : label;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          padding: const EdgeInsets.only(right: 5),
          child: Text(
            baseLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          ":",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
