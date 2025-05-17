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

  Color _getStatusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade600;
      case 'disapproved':
        return Colors.red.shade600;
      case 'waiting':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _buildAttributeRow({required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
                color: Colors.black,
              ),
            ),
          ),
          const Text(
            ' : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.0,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, ReportDetail detail) {
    final productRepository = RepositoryProvider.of<ProductRepository>(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: _getStatusBorderColor(report.status),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: productRepository.fetchProduct(detail.upc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Loading product...'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final product = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?.name ?? detail.upc,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UPC: ${detail.upc}',
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Text(
                    detail.upc,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  );
                }
              },
            ),
            const Divider(),
            Text(
              'Quantity: ${detail.quantity}',
              style: const TextStyle(
                fontSize: 13.0,
                color: Colors.black,
              ),
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
        title: Text(
          DateFormat('yyyy-MM-dd').format(report.dateCreated),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: BlocBuilder<OwnerApprovalDetailBloc, OwnerApprovalDetailState>(
        builder: (context, state) {
          if (state is OwnerApprovalDetailLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading report details...'),
                ],
              ),
            );
          } else if (state is OwnerApprovalDetailLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<OwnerApprovalDetailBloc>()
                    .add(FetchOwnerApprovalDetails(report.reportId));
              },
              child: Container(
                color: Colors.grey.shade50,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: _getStatusBorderColor(report.status),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Report Information',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAttributeRow(
                                label: 'Type', value: report.type),
                            _buildAttributeRow(
                                label: 'Status', value: report.status),
                            _buildAttributeRow(
                                label: 'User ID',
                                value: report.userId.toString()),
                            _buildAttributeRow(
                              label: 'Date Created',
                              value: DateFormat('yyyy-MM-dd')
                                  .format(report.dateCreated),
                            ),
                            _buildAttributeRow(
                              label: 'Last Updated',
                              value: DateFormat('yyyy-MM-dd HH:mm')
                                  .format(report.lastUpdated),
                            ),
                            if (report.note != null && report.note!.isNotEmpty)
                              _buildAttributeRow(
                                  label: 'Note', value: report.note!),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Report Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    state.details.isEmpty
                        ? Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: BorderSide(
                                  color: Colors.grey.shade300, width: 1.0),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 16),
                                  Text(
                                    'No report details available',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: state.details
                                .map((detail) =>
                                    _buildDetailCard(context, detail))
                                .toList(),
                          ),
                  ],
                ),
              ),
            );
          } else if (state is OwnerApprovalDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<OwnerApprovalDetailBloc>()
                          .add(FetchOwnerApprovalDetails(report.reportId));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data.'));
        },
      ),
    );
  }
}
