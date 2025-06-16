import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/bloc/owner_approval/owner_approval_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/view/owner_approval_screen.dart';
import 'package:primamobile/repository/report_repository.dart';

class OwnerApprovalPage extends StatelessWidget {
  const OwnerApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final now = DateTime.now();
    return BlocProvider(
      create: (context) => OwnerApprovalBloc(
        reportRepository: RepositoryProvider.of<ReportRepository>(context),
      )..add(FetchOwnerApprovals(
          // selectedDateRange: 'All Dates', // Your desired default
          // startDate: now.subtract(const Duration(days: 7)),
          // endDate: now,
          // sortBy: 'date_created',
          // sortOrder: 'desc',
          // status: null, // or whatever default status you want
          // reportType: null, // or a specific report type
          )),
      child: const OwnerApprovalScreen(),
    );
  }
}
