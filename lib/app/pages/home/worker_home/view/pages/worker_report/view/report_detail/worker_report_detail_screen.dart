import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report_detail/bloc/worker_report_detail_bloc.dart';

class WorkerReportDetailScreen extends StatelessWidget {
  final Report report;

  const WorkerReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details - Report ${report.reportId}'),
      ),
      body: BlocBuilder<WorkerReportDetailBloc, WorkerReportDetailState>(
        builder: (context, state) {
          if (state is WorkerReportDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkerReportDetailLoaded) {
            final details = state.details;
            if (details.isEmpty) {
              return const Center(child: Text('No report details available.'));
            }
            return ListView.builder(
              itemCount: details.length,
              itemBuilder: (context, index) {
                final detail = details[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('UPC: ${detail.upc}'),
                    subtitle: Text('Quantity: ${detail.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Optionally add edit functionality here.
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<WorkerReportDetailBloc>().add(
                                  DeleteWorkerReportDetail(
                                      report.reportId, detail.reportDetailId),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
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
          // For example, show a dialog similar to the AddReportPage.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
