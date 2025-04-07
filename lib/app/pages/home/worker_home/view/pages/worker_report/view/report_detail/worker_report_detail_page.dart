import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report/worker_report_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report_detail/bloc/worker_report_detail_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/view/report_detail/worker_report_detail_screen.dart';
import 'package:primamobile/repository/report_detail_repository.dart';
import 'package:primamobile/repository/report_repository.dart';

class WorkerReportDetailPage extends StatelessWidget {
  final Report report;

  const WorkerReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkerReportDetailBloc>(
          create: (context) => WorkerReportDetailBloc(
            reportDetailRepository:
                RepositoryProvider.of<ReportDetailRepository>(context),
          )..add(FetchWorkerReportDetails(report.reportId)),
        ),
        // Create a new WorkerReportBloc instead of trying to access the parent one
        BlocProvider<WorkerReportBloc>(
          create: (context) => WorkerReportBloc(
            reportRepository: RepositoryProvider.of<ReportRepository>(context),
          ),
        ),
      ],
      child: WorkerReportDetailScreen(report: report),
    );
  }
}
