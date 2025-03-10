import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report_detail/bloc/worker_report_detail_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/view/report_detail/worker_report_detail_screen.dart';
import 'package:primamobile/repository/report_detail_repository.dart';

class WorkerReportDetailPage extends StatelessWidget {
  final Report report;

  const WorkerReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerReportDetailBloc(
        reportDetailRepository:
            RepositoryProvider.of<ReportDetailRepository>(context),
      )..add(FetchWorkerReportDetails(report.reportId)),
      child: WorkerReportDetailScreen(report: report),
    );
  }
}
