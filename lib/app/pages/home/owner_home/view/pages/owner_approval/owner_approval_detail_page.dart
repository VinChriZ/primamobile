import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/bloc/owner_approval_detail_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/owner_approval/view/owner_approval_detail_screen.dart';
import 'package:primamobile/repository/report_detail_repository.dart';

class OwnerApprovalDetailPage extends StatelessWidget {
  final Report report;
  const OwnerApprovalDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OwnerApprovalDetailBloc(
        reportDetailRepository:
            RepositoryProvider.of<ReportDetailRepository>(context),
      )..add(FetchOwnerApprovalDetails(report.reportId)),
      child: OwnerApprovalDetailScreen(report: report),
    );
  }
}
