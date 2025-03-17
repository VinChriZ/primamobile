import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/bloc/owner_approval/owner_approval_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/view/owner_approval_detail_page.dart';

class OwnerApprovalScreen extends StatelessWidget {
  const OwnerApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Approvals')),
      body: BlocBuilder<OwnerApprovalBloc, OwnerApprovalState>(
        builder: (context, state) {
          if (state is OwnerApprovalLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OwnerApprovalLoaded) {
            final List<Report> reports = List<Report>.from(state.reports);
            if (reports.isEmpty) {
              return const Center(child: Text('No pending reports.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<OwnerApprovalBloc>()
                    .add(const FetchOwnerApprovals());
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

                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OwnerApprovalDetailPage(report: report),
                        ),
                      );
                      context
                          .read<OwnerApprovalBloc>()
                          .add(const FetchOwnerApprovals());
                    },
                    child: Card(
                      color: cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(report.dateCreated),
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text('Type: ${report.type}'),
                            Text('Status: ${report.status}'),
                            const SizedBox(height: 12.0),
                            // Only display approve/deny buttons if report is waiting.
                            if (status == 'waiting')
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.read<OwnerApprovalBloc>().add(
                                            ApproveReport(report.reportId));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      child: const Text('Approve',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<OwnerApprovalBloc>()
                                            .add(DenyReport(report.reportId));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text('Deny',
                                          style:
                                              TextStyle(color: Colors.white)),
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
          } else if (state is OwnerApprovalError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data.'));
        },
      ),
    );
  }
}
