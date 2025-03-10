import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/repository/report_repository.dart';

part 'worker_report_event.dart';
part 'worker_report_state.dart';

class WorkerReportBloc extends Bloc<WorkerReportEvent, WorkerReportState> {
  final ReportRepository reportRepository;

  WorkerReportBloc({required this.reportRepository})
      : super(WorkerReportInitial()) {
    on<FetchWorkerReport>(_onFetchWorkerReport);
    on<DeleteWorkerReport>(_onDeleteWorkerReport);
    // You can add more events like UpdateWorkerReport if needed.
  }

  Future<void> _onFetchWorkerReport(
      FetchWorkerReport event, Emitter<WorkerReportState> emit) async {
    emit(WorkerReportLoading());
    try {
      final reports = await reportRepository.fetchReports(
        startDate: event.startDate,
        endDate: event.endDate,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        status: event.status,
        reportType: event.reportType,
      );
      // Optionally, apply client-side sorting if needed.
      emit(WorkerReportLoaded(
        reports: reports,
        selectedDateRange: event.selectedDateRange,
        selectedSortBy: event.sortBy,
        selectedSortOrder: event.sortOrder,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(WorkerReportError('Failed to fetch reports: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteWorkerReport(
      DeleteWorkerReport event, Emitter<WorkerReportState> emit) async {
    if (state is WorkerReportLoaded) {
      final currentState = state as WorkerReportLoaded;
      try {
        await reportRepository.removeReport(event.reportId);
        final updatedReports = currentState.reports
            .where((report) => report.reportId != event.reportId)
            .toList();
        emit(WorkerReportLoaded(
          reports: updatedReports,
          selectedDateRange: currentState.selectedDateRange,
          selectedSortBy: currentState.selectedSortBy,
          selectedSortOrder: currentState.selectedSortOrder,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
        ));
      } catch (e) {
        emit(WorkerReportError('Failed to delete report: ${e.toString()}'));
      }
    }
  }
}
