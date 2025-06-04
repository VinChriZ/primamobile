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

    //  default values.
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

  /// widget to build a row
  Widget _buildAttributeRow(String label, String value) {
    String baseLabel =
        label.endsWith(':') ? label.substring(0, label.length - 1) : label;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<WorkerReportBloc, WorkerReportState>(
          builder: (context, state) {
            final selectedDateRange = (state is WorkerReportLoaded)
                ? state.selectedDateRange
                : 'All Dates';
            final selectedSortBy = (state is WorkerReportLoaded)
                ? state.selectedSortBy
                : 'date_created';
            final selectedSortOrder = (state is WorkerReportLoaded)
                ? state.selectedSortOrder
                : 'desc';

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Date Range dropdown
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
                      // Sort By dropdown
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
                                value: 'date_created',
                                child: Text('Date Created',
                                    style: TextStyle(fontSize: 13))),
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
                      const SizedBox(width: 10.0),
                      // Sort Order dropdown
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
                              final sortOrder =
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
                            // padding: const EdgeInsets.all(8.0),
                            itemCount: state.reports.length,
                            itemBuilder: (context, index) {
                              final report = state.reports[index];
                              final status = report.status.toLowerCase();

                              final bool isEditable = status != 'approved';

                              // border color
                              BorderSide borderSide;
                              if (status == 'waiting') {
                                borderSide = BorderSide(
                                    color: Colors.blue.shade300, width: 1.5);
                              } else if (status == 'approved') {
                                borderSide = BorderSide(
                                    color: Colors.green.shade300, width: 1.5);
                              } else {
                                // disapproved
                                borderSide = BorderSide(
                                    color: Colors.red.shade300, width: 1.5);
                              }

                              String capitalizedStatus = '';
                              if (status == 'waiting') {
                                capitalizedStatus = 'Waiting';
                              } else if (status == 'approved') {
                                capitalizedStatus = 'Approved';
                              } else if (status == 'disapproved') {
                                capitalizedStatus = 'Disapproved';
                              } else {
                                capitalizedStatus = report.status;
                              }

                              IconData statusIcon;
                              Color statusColor;
                              if (status == 'waiting') {
                                statusIcon = Icons.hourglass_empty;
                                statusColor = Colors.orange;
                              } else if (status == 'approved') {
                                statusIcon = Icons.check_circle;
                                statusColor = Colors.green;
                              } else {
                                statusIcon = Icons.cancel;
                                statusColor = Colors.red;
                              }

                              return InkWell(
                                onTap: () async {
                                  // Navigate to worker report detail screen
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WorkerReportDetailPage(
                                              report: report),
                                    ),
                                  );
                                  // Refresh list after
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
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 3,
                                    shadowColor: Colors.black26,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: borderSide,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Report: ${DateFormat('yyyy-MM-dd').format(report.dateCreated)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Divider(
                                              color: status == 'waiting'
                                                  ? Colors.blue.shade300
                                                  : status == 'approved'
                                                      ? Colors.green.shade300
                                                      : Colors.red.shade300,
                                              thickness: 1),
                                          const SizedBox(height: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildAttributeRow(
                                                  "Type", report.type),
                                              const SizedBox(height: 6.0),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 100,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5),
                                                    child: const Text(
                                                      "Status",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Text(
                                                    ":",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          statusIcon,
                                                          color: statusColor,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          capitalizedStatus,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: statusColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6.0),
                                              _buildAttributeRow(
                                                "Created",
                                                DateFormat('dd MMM yyyy')
                                                    .format(report.dateCreated),
                                              ),
                                              const SizedBox(height: 6.0),
                                              _buildAttributeRow(
                                                "Updated",
                                                DateFormat('dd MMM yyyy HH:mm')
                                                    .format(report.lastUpdated),
                                              ),

                                              const SizedBox(height: 12.0),
                                              // Only show edit/delete buttons if the report is editable
                                              if (isEditable) ...[
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 34,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .blue[600],
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            final updated =
                                                                await Navigator
                                                                    .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      EditReportPage(
                                                                          report:
                                                                              report)),
                                                            );
                                                            if (updated !=
                                                                null) {
                                                              context
                                                                  .read<
                                                                      WorkerReportBloc>()
                                                                  .add(
                                                                    FetchWorkerReport(
                                                                      selectedDateRange:
                                                                          state
                                                                              .selectedDateRange,
                                                                      startDate:
                                                                          state
                                                                              .startDate,
                                                                      endDate: state
                                                                          .endDate,
                                                                      sortBy: state
                                                                          .selectedSortBy,
                                                                      sortOrder:
                                                                          state
                                                                              .selectedSortOrder,
                                                                    ),
                                                                  );
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Edit',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 34,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.red[400],
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (dialogContext) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Delete Report'),
                                                                  content:
                                                                      const Text(
                                                                          'Are you sure you want to delete this report?'),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(dialogContext),
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        context
                                                                            .read<WorkerReportBloc>()
                                                                            .add(DeleteWorkerReport(report.reportId));
                                                                        Navigator.pop(
                                                                            dialogContext);
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                              content: Text('Report deleted successfully.')),
                                                                        );
                                                                      },
                                                                      child: const Text(
                                                                          'Delete'),
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
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (state is WorkerReportError) {
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
        icon: const Icon(Icons.add),
        label: const Text("Add Report"),
        backgroundColor: Colors.blue[700],
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
      ),
    );
  }
}
