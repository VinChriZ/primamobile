import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/report/report_detail.dart';
import 'package:primamobile/repository/report_detail_repository.dart';

part 'owner_approval_detail_event.dart';
part 'owner_approval_detail_state.dart';

class OwnerApprovalDetailBloc
    extends Bloc<OwnerApprovalDetailEvent, OwnerApprovalDetailState> {
  final ReportDetailRepository reportDetailRepository;
  OwnerApprovalDetailBloc({required this.reportDetailRepository})
      : super(OwnerApprovalDetailInitial()) {
    on<FetchOwnerApprovalDetails>(_onFetchOwnerApprovalDetails);
  }

  Future<void> _onFetchOwnerApprovalDetails(FetchOwnerApprovalDetails event,
      Emitter<OwnerApprovalDetailState> emit) async {
    emit(OwnerApprovalDetailLoading());
    try {
      final details =
          await reportDetailRepository.fetchReportDetails(event.reportId);
      emit(OwnerApprovalDetailLoaded(
          reportId: event.reportId, details: details));
    } catch (e) {
      emit(
          OwnerApprovalDetailError('Failed to fetch details: ${e.toString()}'));
    }
  }
}
