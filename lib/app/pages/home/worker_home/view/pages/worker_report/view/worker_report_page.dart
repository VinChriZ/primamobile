import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/worker_report_bloc.dart';
import 'package:primamobile/repository/report_repository.dart';
import 'worker_report_screen.dart';

class WorkerReportPage extends StatelessWidget {
  const WorkerReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerReportBloc(
        reportRepository: RepositoryProvider.of<ReportRepository>(context),
      )..add(const FetchWorkerReport()),
      child: const WorkerReportScreen(),
    );
  }
}
