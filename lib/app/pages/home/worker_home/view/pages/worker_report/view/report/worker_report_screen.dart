import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report/worker_report_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/view/report/add_report_page.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/view/report/edit_report_page.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/view/report_detail/worker_report_detail_page.dart';

class WorkerReportScreen extends StatelessWidget {
  const WorkerReportScreen({super.key});

  Future<void> _handleDateRangeChange(
      BuildContext context, String? value, WorkerReportState state) async {
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
        if (state is WorkerReportLoaded) {
          selectedDateRange = state.selectedDateRange;
          startDate = state.startDate;
          endDate = state.endDate;
        }
      }
    } else {
      startDate = null;
      endDate = null;
    }

    // Use current sort filters from state, or default values.
    String sortBy =
        (state is WorkerReportLoaded) ? state.selectedSortBy : 'date_created';
    String sortOrder =
        (state is WorkerReportLoaded) ? state.selectedSortOrder : 'desc';

    context.read<WorkerReportBloc>().add(
          FetchWorkerReport(
            selectedDateRange: selectedDateRange,
            startDate: startDate,
            endDate: endDate,
            sortBy: sortBy,
            sortOrder: sortOrder,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Reports')),
      body: BlocBuilder<WorkerReportBloc, WorkerReportState>(
        builder: (context, state) {
          final selectedDateRange = (state is WorkerReportLoaded)
              ? state.selectedDateRange
              : 'All Dates';
          final selectedSortBy = (state is WorkerReportLoaded)
              ? state.selectedSortBy
              : 'date_created';
          final selectedSortOrder =
              (state is WorkerReportLoaded) ? state.selectedSortOrder : 'desc';

          return Column(
            children: [
              // Filters row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Row(
                  children: [
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
                              value: 'Last 7 Days', child: Text('Last 7 Days')),
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
                    // Sort By dropdown
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
                              value: 'date_created',
                              child: Text('Date Created')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<WorkerReportBloc>().add(
                                  FetchWorkerReport(
                                    selectedDateRange: selectedDateRange,
                                    startDate: (state is WorkerReportLoaded)
                                        ? state.startDate
                                        : null,
                                    endDate: (state is WorkerReportLoaded)
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
                    // Sort Order dropdown
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sort Order',
                          border: OutlineInputBorder(),
                        ),
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
                            context.read<WorkerReportBloc>().add(
                                  FetchWorkerReport(
                                    selectedDateRange: selectedDateRange,
                                    startDate: (state is WorkerReportLoaded)
                                        ? state.startDate
                                        : null,
                                    endDate: (state is WorkerReportLoaded)
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
              // Report List
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state is WorkerReportLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is WorkerReportLoaded) {
                      if (state.reports.isEmpty) {
                        return const Center(
                            child: Text('No reports available.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<WorkerReportBloc>().add(
                                FetchWorkerReport(
                                  selectedDateRange: state.selectedDateRange,
                                  startDate: state.startDate,
                                  endDate: state.endDate,
                                  sortBy: state.selectedSortBy,
                                  sortOrder: state.selectedSortOrder,
                                ),
                              );
                        },
                        child: ListView.builder(
                          itemCount: state.reports.length,
                          itemBuilder: (context, index) {
                            final report = state.reports[index];
                            return Card(
                              color: Colors.lightBlue[100],
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              elevation: 2,
                              child: InkWell(
                                onTap: () async {
                                  // Navigate to the worker report detail screen
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WorkerReportDetailPage(
                                              report: report),
                                    ),
                                  );
                                  // Refresh list after returning:
                                  context.read<WorkerReportBloc>().add(
                                        FetchWorkerReport(
                                          selectedDateRange:
                                              state.selectedDateRange,
                                          startDate: state.startDate,
                                          endDate: state.endDate,
                                          sortBy: state.selectedSortBy,
                                          sortOrder: state.selectedSortOrder,
                                        ),
                                      );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('yyyy-MM-dd')
                                            .format(report.dateCreated),
                                        style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12.0),
                                      Text("Type: ${report.type}"),
                                      const SizedBox(height: 6.0),
                                      Text("Status: ${report.status}"),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        "Last Updated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(report.lastUpdated)}",
                                      ),
                                      const SizedBox(height: 12.0),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                  backgroundColor: Colors.blue),
                                              onPressed: () async {
                                                final updated =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditReportPage(
                                                              report: report)),
                                                );
                                                if (updated != null) {
                                                  context
                                                      .read<WorkerReportBloc>()
                                                      .add(
                                                        FetchWorkerReport(
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
                                              child: const Text('Edit',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Delete Report'),
                                                      content: const Text(
                                                          'Are you sure you want to delete this report?'),
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
                                                                    WorkerReportBloc>()
                                                                .add(DeleteWorkerReport(
                                                                    report
                                                                        .reportId));
                                                            Navigator.pop(
                                                                dialogContext);
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Report deleted successfully.')),
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
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else if (state is WorkerReportError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReportPage()),
          );
          if (result == true) {
            final currentState = context.read<WorkerReportBloc>().state;
            if (currentState is WorkerReportLoaded) {
              context.read<WorkerReportBloc>().add(
                    FetchWorkerReport(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
