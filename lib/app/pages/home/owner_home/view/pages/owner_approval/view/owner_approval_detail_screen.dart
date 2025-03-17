import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/models/report/report_detail.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/bloc/owner_approval_detail/owner_approval_detail_bloc.dart';
import 'package:primamobile/repository/product_repository.dart';

class OwnerApprovalDetailScreen extends StatelessWidget {
  final Report report;
  const OwnerApprovalDetailScreen({super.key, required this.report});

  Widget _buildAttributeRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
              width: 150,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, ReportDetail detail) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fetch and display the product name instead of UPC.
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
                    product?.name ?? detail.upc,
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy-MM-dd').format(report.dateCreated)),
      ),
      body: BlocBuilder<OwnerApprovalDetailBloc, OwnerApprovalDetailState>(
        builder: (context, state) {
          if (state is OwnerApprovalDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OwnerApprovalDetailLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<OwnerApprovalDetailBloc>()
                    .add(FetchOwnerApprovalDetails(report.reportId));
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAttributeRow(
                      label: 'User ID:', value: report.userId.toString()),
                  _buildAttributeRow(
                      label: 'Date Created:',
                      value:
                          DateFormat('yyyy-MM-dd').format(report.dateCreated)),
                  _buildAttributeRow(
                      label: 'Last Updated:',
                      value: DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(report.lastUpdated)),
                  _buildAttributeRow(label: 'Type:', value: report.type),
                  _buildAttributeRow(label: 'Status:', value: report.status),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Report Details:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...state.details
                      .map((detail) => _buildDetailCard(context, detail))
                      .toList(),
                ],
              ),
            );
          } else if (state is OwnerApprovalDetailError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data.'));
        },
      ),
    );
  }
}
