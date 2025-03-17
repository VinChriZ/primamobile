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
  }

  Future<void> _onFetchOwnerApprovals(
      FetchOwnerApprovals event, Emitter<OwnerApprovalState> emit) async {
    emit(OwnerApprovalLoading());
    try {
      // Fetch all reports without filtering.
      final reports = await reportRepository.fetchReports();
      emit(OwnerApprovalLoaded(reports: reports));
    } catch (e) {
      emit(OwnerApprovalError('Failed to fetch reports: ${e.toString()}'));
    }
  }

  Future<void> _onApproveReport(
      ApproveReport event, Emitter<OwnerApprovalState> emit) async {
    try {
      // Use new repository function for approval
      await reportRepository.approveReport(event.reportId);
      add(const FetchOwnerApprovals());
    } catch (e) {
      emit(OwnerApprovalError('Failed to approve report: ${e.toString()}'));
    }
  }

  Future<void> _onDenyReport(
      DenyReport event, Emitter<OwnerApprovalState> emit) async {
    try {
      // Use new repository function for denial
      await reportRepository.denyReport(event.reportId);
      add(const FetchOwnerApprovals());
    } catch (e) {
      emit(OwnerApprovalError('Failed to deny report: ${e.toString()}'));
    }
  }
}
