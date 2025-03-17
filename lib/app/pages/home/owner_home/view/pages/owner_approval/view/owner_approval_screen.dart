import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/bloc/owner_approval/owner_approval_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/view/owner_approval_detail_page.dart';

class OwnerApprovalScreen extends StatelessWidget {
  const OwnerApprovalScreen({super.key});

  Future<void> _handleDateRangeChange(
      BuildContext context, String? value, OwnerApprovalState state) async {
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
        if (state is OwnerApprovalLoaded) {
          selectedDateRange = state.selectedDateRange;
          startDate = state.startDate;
          endDate = state.endDate;
        }
      }
    } else {
      startDate = null;
      endDate = null;
    }

    // Get current sort and filter values or use defaults
    String sortBy = 'date_created';
    String sortOrder = 'desc';
    String? status;
    String? reportType;

    if (state is OwnerApprovalLoaded) {
      sortBy = state.selectedSortBy;
      sortOrder = state.selectedSortOrder;
      status = state.selectedStatus;
      reportType = state.selectedReportType;
    }

    context.read<OwnerApprovalBloc>().add(
          FetchOwnerApprovals(
            selectedDateRange: selectedDateRange,
            startDate: startDate,
            endDate: endDate,
            sortBy: sortBy,
            sortOrder: sortOrder,
            status: status,
            reportType: reportType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Approvals')),
      body: BlocBuilder<OwnerApprovalBloc, OwnerApprovalState>(
        builder: (context, state) {
          final selectedDateRange = (state is OwnerApprovalLoaded)
              ? state.selectedDateRange
              : 'All Dates';
          final selectedSortBy = (state is OwnerApprovalLoaded)
              ? state.selectedSortBy
              : 'date_created';
          final selectedSortOrder =
              (state is OwnerApprovalLoaded) ? state.selectedSortOrder : 'desc';
          final selectedStatus =
              (state is OwnerApprovalLoaded) ? state.selectedStatus : null;

          return Column(
            children: [
              // Filters row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Row(
                  children: [
                    // Date Range dropdown
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
                          if (value != null && state is OwnerApprovalLoaded) {
                            final currentState = state;
                            context.read<OwnerApprovalBloc>().add(
                                  FetchOwnerApprovals(
                                    selectedDateRange:
                                        currentState.selectedDateRange,
                                    startDate: currentState.startDate,
                                    endDate: currentState.endDate,
                                    sortBy: value,
                                    sortOrder: currentState.selectedSortOrder,
                                    status: currentState.selectedStatus,
                                    reportType: currentState.selectedReportType,
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
                          if (value != null && state is OwnerApprovalLoaded) {
                            String sortOrder =
                                value.toLowerCase() == 'ascending'
                                    ? 'asc'
                                    : 'desc';
                            final currentState = state;
                            context.read<OwnerApprovalBloc>().add(
                                  FetchOwnerApprovals(
                                    selectedDateRange:
                                        currentState.selectedDateRange,
                                    startDate: currentState.startDate,
                                    endDate: currentState.endDate,
                                    sortBy: currentState.selectedSortBy,
                                    sortOrder: sortOrder,
                                    status: currentState.selectedStatus,
                                    reportType: currentState.selectedReportType,
                                  ),
                                );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    // Status Filter dropdown
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedStatus,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(
                              value: 'waiting', child: Text('Waiting')),
                          DropdownMenuItem(
                              value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(
                              value: 'disapproved', child: Text('Disapproved')),
                        ],
                        onChanged: (value) {
                          if (state is OwnerApprovalLoaded) {
                            final currentState = state;
                            context.read<OwnerApprovalBloc>().add(
                                  FetchOwnerApprovals(
                                    selectedDateRange:
                                        currentState.selectedDateRange,
                                    startDate: currentState.startDate,
                                    endDate: currentState.endDate,
                                    sortBy: currentState.selectedSortBy,
                                    sortOrder: currentState.selectedSortOrder,
                                    status: value,
                                    reportType: currentState.selectedReportType,
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
                    if (state is OwnerApprovalLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is OwnerApprovalLoaded) {
                      final List<Report> reports =
                          List<Report>.from(state.reports);
                      if (reports.isEmpty) {
                        return const Center(
                            child: Text('No reports available.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<OwnerApprovalBloc>().add(
                                FetchOwnerApprovals(
                                  selectedDateRange: state.selectedDateRange,
                                  startDate: state.startDate,
                                  endDate: state.endDate,
                                  sortBy: state.selectedSortBy,
                                  sortOrder: state.selectedSortOrder,
                                  status: state.selectedStatus,
                                  reportType: state.selectedReportType,
                                ),
                              );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            final status = report.status.toLowerCase();
                            Color? cardColor;
                            if (status == 'waiting') {
                              cardColor = Colors.lightBlue[100];
                            } else if (status == 'approved') {
                              cardColor = Colors.lightGreen[100];
                            } else if (status == 'disapproved') {
                              cardColor = Colors.red[100];
                            } else {
                              cardColor = Colors.white; // fallback
                            }

                            // Capitalize the status
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

                            return InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OwnerApprovalDetailPage(report: report),
                                  ),
                                );
                                context.read<OwnerApprovalBloc>().add(
                                      FetchOwnerApprovals(
                                        selectedDateRange:
                                            state.selectedDateRange,
                                        startDate: state.startDate,
                                        endDate: state.endDate,
                                        sortBy: state.selectedSortBy,
                                        sortOrder: state.selectedSortOrder,
                                        status: state.selectedStatus,
                                        reportType: state.selectedReportType,
                                      ),
                                    );
                              },
                              child: Card(
                                color: cardColor,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
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
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12.0),

                                      // Improved alignment for report information
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Labels column
                                          const SizedBox(
                                            width: 70,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Type',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(height: 4),
                                                Text('Status',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(height: 4),
                                                Text('Created',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),

                                          // Separator column
                                          const SizedBox(
                                            width: 16,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(':'),
                                                SizedBox(height: 4),
                                                Text(':'),
                                                SizedBox(height: 4),
                                                Text(':'),
                                              ],
                                            ),
                                          ),

                                          // Values column
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(report.type),
                                                const SizedBox(height: 4),
                                                Text(
                                                  capitalizedStatus, // Using capitalized status
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: status == 'waiting'
                                                        ? Colors.blue[700]
                                                        : status == 'approved'
                                                            ? Colors.green[700]
                                                            : Colors.red[700],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(DateFormat(
                                                        'dd MMM yyyy') // Removed the time portion
                                                    .format(
                                                        report.dateCreated)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16.0),

                                      // Only display approve/deny buttons if report is waiting.
                                      if (status == 'waiting')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  context
                                                      .read<OwnerApprovalBloc>()
                                                      .add(ApproveReport(
                                                          report.reportId));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green),
                                                child: const Text('Approve',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  context
                                                      .read<OwnerApprovalBloc>()
                                                      .add(DenyReport(
                                                          report.reportId));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.orange[800]),
                                                child: const Text('Deny',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      // Add spacing if the approve/deny buttons are shown
                                      if (status == 'waiting')
                                        const SizedBox(height: 12.0),
                                      // Delete button - reverted to original style
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
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
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                OwnerApprovalBloc>()
                                                            .add(DeleteOwnerApproval(
                                                                report
                                                                    .reportId));
                                                        Navigator.pop(
                                                            dialogContext);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  'Report deleted successfully.')),
                                                        );
                                                      },
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else if (state is OwnerApprovalError) {
                      return Center(child: Text(state.message));
                    }
                    return const Center(child: Text('No data.'));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
