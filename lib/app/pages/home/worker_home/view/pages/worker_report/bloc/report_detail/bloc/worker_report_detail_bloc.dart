import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/report/report_detail.dart';
import 'package:primamobile/repository/report_detail_repository.dart';

part 'worker_report_detail_event.dart';
part 'worker_report_detail_state.dart';

class WorkerReportDetailBloc
    extends Bloc<WorkerReportDetailEvent, WorkerReportDetailState> {
  final ReportDetailRepository reportDetailRepository;

  WorkerReportDetailBloc({required this.reportDetailRepository})
      : super(WorkerReportDetailInitial()) {
    on<FetchWorkerReportDetails>(_onFetchWorkerReportDetails);
    on<AddWorkerReportDetail>(_onAddWorkerReportDetail);
    on<UpdateWorkerReportDetail>(_onUpdateWorkerReportDetail);
    on<DeleteWorkerReportDetail>(_onDeleteWorkerReportDetail);
  }

  Future<void> _onFetchWorkerReportDetails(FetchWorkerReportDetails event,
      Emitter<WorkerReportDetailState> emit) async {
    emit(WorkerReportDetailLoading());
    try {
      final details =
          await reportDetailRepository.fetchReportDetails(event.reportId);
      emit(
          WorkerReportDetailLoaded(reportId: event.reportId, details: details));
    } catch (e) {
      emit(WorkerReportDetailError(
          'Failed to fetch report details: ${e.toString()}'));
    }
  }

  Future<void> _onAddWorkerReportDetail(AddWorkerReportDetail event,
      Emitter<WorkerReportDetailState> emit) async {
    try {
      await reportDetailRepository.addReportDetail(
          event.reportId, event.fields);
      add(FetchWorkerReportDetails(event.reportId));
    } catch (e) {
      emit(WorkerReportDetailError(
          'Failed to add report detail: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateWorkerReportDetail(UpdateWorkerReportDetail event,
      Emitter<WorkerReportDetailState> emit) async {
    try {
      await reportDetailRepository.updateReportDetail(
          event.reportId, event.detailId, event.fields);
      add(FetchWorkerReportDetails(event.reportId));
    } catch (e) {
      emit(WorkerReportDetailError(
          'Failed to update report detail: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteWorkerReportDetail(DeleteWorkerReportDetail event,
      Emitter<WorkerReportDetailState> emit) async {
    try {
      await reportDetailRepository.removeReportDetail(
          event.reportId, event.detailId);
      add(FetchWorkerReportDetails(event.reportId));
    } catch (e) {
      emit(WorkerReportDetailError(
          'Failed to delete report detail: ${e.toString()}'));
    }
  }
}
