import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/models/report/report_detail.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report_detail/bloc/worker_report_detail_bloc.dart';

class WorkerReportDetailScreen extends StatelessWidget {
  final Report report;

  const WorkerReportDetailScreen({super.key, required this.report});

  Widget _buildAttributeRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 150.0,
            child: Text(
              label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetailsList(
      BuildContext context, List<ReportDetail> details) {
    if (details.isEmpty) {
      return const Center(child: Text('No report details available.'));
    }
    return ListView.builder(
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return _buildReportDetailCard(context, detail);
      },
    );
  }

  Widget _buildReportDetailCard(BuildContext context, ReportDetail detail) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPC: ${detail.upc}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Quantity: ${detail.quantity}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 4.0),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement edit functionality if needed.
                      // For example, show a dialog to edit the detail.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<WorkerReportDetailBloc>().add(
                            DeleteWorkerReportDetail(
                                report.reportId, detail.reportDetailId),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the report date as the app bar title.
    final String reportDateStr =
        DateFormat('yyyy-MM-dd').format(report.dateCreated);
    return Scaffold(
      appBar: AppBar(
        title: Text(reportDateStr),
        centerTitle: true,
      ),
      body: BlocBuilder<WorkerReportDetailBloc, WorkerReportDetailState>(
        builder: (context, state) {
          if (state is WorkerReportDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkerReportDetailLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WorkerReportDetailBloc>().add(
                      FetchWorkerReportDetails(report.reportId),
                    );
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAttributeRow(
                    label: 'User ID:',
                    value: report.userId.toString(),
                  ),
                  _buildAttributeRow(
                    label: 'Date Created:',
                    value: DateFormat('yyyy-MM-dd').format(report.dateCreated),
                  ),
                  _buildAttributeRow(
                    label: 'Last Updated:',
                    value: DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(report.lastUpdated),
                  ),
                  _buildAttributeRow(
                    label: 'Type:',
                    value: report.type,
                  ),
                  _buildAttributeRow(
                    label: 'Status:',
                    value: report.status,
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Product List:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 400, // Adjust height as needed.
                    child: _buildReportDetailsList(context, state.details),
                  ),
                ],
              ),
            );
          } else if (state is WorkerReportDetailError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement adding a new report detail.
          // For example, show a dialog similar to your AddReportPage.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
