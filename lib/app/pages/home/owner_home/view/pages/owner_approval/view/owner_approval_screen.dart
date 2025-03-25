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

  /// Helper widget to build a card with consistent styling across the app.
  // ignore: unused_element
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
          side: BorderSide(color: Colors.blue.shade100, width: 1),
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
                        size: 20,
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
                Divider(color: Colors.blue.shade100, thickness: 1),
                const SizedBox(height: 6), // Decreased from 8
              ],
              child,
            ],
          ),
        ),
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
          width: 100,
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

  /// Show dialog to get notes from owner before approving or denying
  Future<void> _showNoteDialog(
      BuildContext context, Report report, bool isApprove) async {
    final TextEditingController noteController =
        TextEditingController(text: report.note ?? '');

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isApprove ? 'Approve Report' : 'Deny Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isApprove
                    ? 'Add any notes before approving this report:'
                    : 'Please provide a reason for denying this report:'),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: isApprove
                        ? 'Optional notes...'
                        : 'Reason for denial...',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final note = noteController.text.trim();

                // First update the note, then approve or deny the report
                context.read<OwnerApprovalBloc>().add(
                      UpdateReportNote(
                        reportId: report.reportId,
                        note: note,
                        onSuccess: () {
                          // After note is updated, proceed with approval/denial
                          if (isApprove) {
                            context.read<OwnerApprovalBloc>().add(
                                  ApproveReport(report.reportId),
                                );
                          } else {
                            context.read<OwnerApprovalBloc>().add(
                                  DenyReport(report.reportId),
                                );
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isApprove
                                  ? 'Report approved with note'
                                  : 'Report denied with reason'),
                              backgroundColor:
                                  isApprove ? Colors.green : Colors.orange,
                            ),
                          );
                        },
                        onError: (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update note: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      ),
                    );

                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? Colors.green : Colors.orange[800],
                foregroundColor: Colors.white,
              ),
              child: Text(isApprove ? 'Approve' : 'Deny'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<OwnerApprovalBloc, OwnerApprovalState>(
          builder: (context, state) {
            final selectedDateRange = (state is OwnerApprovalLoaded)
                ? state.selectedDateRange
                : 'All Dates';
            final selectedSortBy = (state is OwnerApprovalLoaded)
                ? state.selectedSortBy
                : 'date_created';
            final selectedSortOrder = (state is OwnerApprovalLoaded)
                ? state.selectedSortOrder
                : 'desc';
            final selectedStatus =
                (state is OwnerApprovalLoaded) ? state.selectedStatus : null;

            return Column(
              children: [
                // Remove the title bar and just keep the filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
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
                                      reportType:
                                          currentState.selectedReportType,
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
                                      reportType:
                                          currentState.selectedReportType,
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
                                value: 'disapproved',
                                child: Text('Disapproved')),
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
                                      reportType:
                                          currentState.selectedReportType,
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
                            // Remove the padding that's making cards appear smaller
                            // padding: const EdgeInsets.all(8.0),
                            itemCount: reports.length,
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              final status = report.status.toLowerCase();

                              // Determine border color based on status
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

                              // Get an icon and color based on status
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
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OwnerApprovalDetailPage(
                                              report: report),
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
                                              fontSize: 16, // Decreased from 18
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 10), // Decreased from 12
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
                                                        fontSize:
                                                            14, // Decreased from 16
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
                                                      fontSize:
                                                          14, // Decreased from 16
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          statusIcon,
                                                          color: statusColor,
                                                          size:
                                                              16, // Decreased from 18
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          capitalizedStatus,
                                                          style: TextStyle(
                                                            fontSize:
                                                                14, // Decreased from 16
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
                                              const SizedBox(height: 12.0),

                                              // Only display approve/deny buttons if report is waiting.
                                              if (status == 'waiting')
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          _showNoteDialog(
                                                              context,
                                                              report,
                                                              true // isApprove = true
                                                              );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      10.0),
                                                        ),
                                                        child: const Text(
                                                          'Approve',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          _showNoteDialog(
                                                              context,
                                                              report,
                                                              false // isApprove = false
                                                              );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .orange[800],
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      10.0),
                                                        ),
                                                        child: const Text(
                                                          'Deny',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if (status == 'waiting')
                                                const SizedBox(height: 8.0),
                                              // Delete button
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
                                                              child: const Text(
                                                                  'Cancel'),
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
                                                              child: const Text(
                                                                  'Delete'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10.0),
                                                  ),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
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
      ),
    );
  }
}
