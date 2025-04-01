import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/repository/report_repository.dart';

part 'owner_approval_event.dart';
part 'owner_approval_state.dart';

class OwnerApprovalBloc extends Bloc<OwnerApprovalEvent, OwnerApprovalState> {
  final ReportRepository reportRepository;
  OwnerApprovalBloc({required this.reportRepository})
      : super(OwnerApprovalInitial()) {
    on<FetchOwnerApprovals>(_onFetchOwnerApprovals);
    on<ApproveReport>(_onApproveReport);
    on<DenyReport>(_onDenyReport);
    on<DeleteOwnerApproval>(_onDeleteOwnerApproval);
    on<UpdateReportNote>(_onUpdateReportNote);
  }

  Future<void> _onFetchOwnerApprovals(
      FetchOwnerApprovals event, Emitter<OwnerApprovalState> emit) async {
    emit(OwnerApprovalLoading());
    try {
      // Fetch reports with filtering and sorting parameters
      final reports = await reportRepository.fetchReports(
        startDate: event.startDate,
        endDate: event.endDate,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        status: event.status,
        reportType: event.reportType,
      );
      emit(OwnerApprovalLoaded(
        reports: reports,
        selectedDateRange: event.selectedDateRange,
        selectedSortBy: event.sortBy,
        selectedSortOrder: event.sortOrder,
        startDate: event.startDate,
        endDate: event.endDate,
        selectedStatus: event.status,
        selectedReportType: event.reportType,
      ));
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const OwnerApprovalError(
            'Login expired, please restart the app and login again'));
      } else {
        emit(const OwnerApprovalError('Failed to fetch reports'));
      }
    }
  }

  Future<void> _onApproveReport(
      ApproveReport event, Emitter<OwnerApprovalState> emit) async {
    try {
      await reportRepository.approveReport(event.reportId);

      // After approval, refresh the list with the same filters
      if (state is OwnerApprovalLoaded) {
        final currentState = state as OwnerApprovalLoaded;
        add(FetchOwnerApprovals(
          selectedDateRange: currentState.selectedDateRange,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          sortBy: currentState.selectedSortBy,
          sortOrder: currentState.selectedSortOrder,
          status: currentState.selectedStatus,
          reportType: currentState.selectedReportType,
        ));
      } else {
        add(const FetchOwnerApprovals());
      }
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const OwnerApprovalError(
            'Login expired, please restart the app and login again'));
      } else {
        emit(OwnerApprovalError('Failed to approve report: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDenyReport(
      DenyReport event, Emitter<OwnerApprovalState> emit) async {
    try {
      await reportRepository.denyReport(event.reportId);

      // After denial, refresh the list with the same filters
      if (state is OwnerApprovalLoaded) {
        final currentState = state as OwnerApprovalLoaded;
        add(FetchOwnerApprovals(
          selectedDateRange: currentState.selectedDateRange,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          sortBy: currentState.selectedSortBy,
          sortOrder: currentState.selectedSortOrder,
          status: currentState.selectedStatus,
          reportType: currentState.selectedReportType,
        ));
      } else {
        add(const FetchOwnerApprovals());
      }
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const OwnerApprovalError(
            'Login expired, please restart the app and login again'));
      } else {
        emit(OwnerApprovalError('Failed to deny report: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteOwnerApproval(
      DeleteOwnerApproval event, Emitter<OwnerApprovalState> emit) async {
    try {
      await reportRepository.removeReport(event.reportId);

      // After deletion, refresh the list with the same filters
      if (state is OwnerApprovalLoaded) {
        final currentState = state as OwnerApprovalLoaded;
        add(FetchOwnerApprovals(
          selectedDateRange: currentState.selectedDateRange,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          sortBy: currentState.selectedSortBy,
          sortOrder: currentState.selectedSortOrder,
          status: currentState.selectedStatus,
          reportType: currentState.selectedReportType,
        ));
      } else {
        add(const FetchOwnerApprovals());
      }
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const OwnerApprovalError(
            'Login expired, please restart the app and login again'));
      } else {
        emit(OwnerApprovalError('Failed to delete report: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateReportNote(
      UpdateReportNote event, Emitter<OwnerApprovalState> emit) async {
    try {
      await reportRepository.updateReportNote(event.reportId, event.note);
      event.onSuccess();
    } catch (e) {
      if (e.toString().contains("401")) {
        event.onError('Login expired, please restart the app and login again');
      } else {
        event.onError(e.toString());
      }
    }
  }
}
