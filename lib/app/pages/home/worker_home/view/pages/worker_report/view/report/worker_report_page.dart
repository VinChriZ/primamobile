import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/view/pages/worker_report/bloc/report/worker_report_bloc.dart';
import 'package:primamobile/repository/report_repository.dart';
import 'worker_report_screen.dart';

class WorkerReportPage extends StatelessWidget {
  const WorkerReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final now = DateTime.now();
    return BlocProvider(
      create: (context) => WorkerReportBloc(
        reportRepository: RepositoryProvider.of<ReportRepository>(context),
      )..add(FetchWorkerReport(
          // selectedDateRange: 'Last 7 Days', // Your desired default
          // startDate: now.subtract(const Duration(days: 7)),
          // endDate: now,
          // sortBy: 'date_created',
          // sortOrder: 'desc',
          )),
      child: const WorkerReportScreen(),
    );
  }
}
