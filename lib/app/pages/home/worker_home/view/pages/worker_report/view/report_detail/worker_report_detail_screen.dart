import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/models/report/report_detail.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report_detail/bloc/worker_report_detail_bloc.dart';
import 'package:primamobile/repository/product_repository.dart';

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
      BuildContext context, Report report, List<ReportDetail> details) {
    if (details.isEmpty) {
      return const Center(child: Text('No report details available.'));
    }
    return ListView.builder(
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return _buildReportDetailCard(context, report, detail);
      },
    );
  }

  Widget _buildReportDetailCard(
      BuildContext context, Report report, ReportDetail detail) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);
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
            // Instead of showing UPC, fetch and show the product name.
            FutureBuilder(
              future: productRepository.fetchProduct(detail.upc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Loading...',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  );
                } else if (snapshot.hasData) {
                  final product = snapshot.data;
                  return Text(
                    product?.name ??
                        detail
                            .upc, // Use product name if not null, otherwise fallback to UPC.
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  );
                } else {
                  return Text(
                    detail.upc,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  );
                }
              },
            ),

            const SizedBox(height: 4.0),
            Text(
              'Quantity: ${detail.quantity}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _showEditReportDetailDialog(context, report, detail),
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
                    onPressed: () =>
                        _showDeleteDetailConfirmation(context, report, detail),
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

  // Shows a dialog to edit the report detail
  void _showEditReportDetailDialog(
      BuildContext context, Report report, ReportDetail detail) {
    final formKey = GlobalKey<FormState>();
    String upc = detail.upc;
    int quantity = detail.quantity;
    final workerReportDetailBloc = context.read<WorkerReportDetailBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Report Detail'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: detail.upc,
                    decoration: const InputDecoration(labelText: 'UPC'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter UPC';
                      }
                      return null;
                    },
                    onSaved: (value) => upc = value!,
                  ),
                  TextFormField(
                    initialValue: detail.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Enter a valid quantity';
                      }
                      return null;
                    },
                    onSaved: (value) => quantity = int.parse(value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  workerReportDetailBloc.add(
                    UpdateWorkerReportDetail(
                      report.reportId,
                      detail.reportDetailId,
                      {
                        'upc': upc,
                        'quantity': quantity,
                      },
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Report detail updated successfully.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Shows a confirmation dialog before deleting a report detail.
  void _showDeleteDetailConfirmation(
      BuildContext context, Report report, ReportDetail detail) {
    final workerReportDetailBloc = context.read<WorkerReportDetailBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Report Detail'),
          content:
              const Text('Are you sure you want to delete this report detail?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                workerReportDetailBloc.add(
                  DeleteWorkerReportDetail(
                      report.reportId, detail.reportDetailId),
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Report detail deleted successfully.')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                context
                    .read<WorkerReportDetailBloc>()
                    .add(FetchWorkerReportDetails(report.reportId));
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
                    child:
                        _buildReportDetailsList(context, report, state.details),
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
          // Implement adding a new report detail, similar to your other add flows.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
