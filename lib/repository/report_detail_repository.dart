import 'package:primamobile/app/models/report/report_detail.dart';
import 'package:primamobile/provider/report_detail_provider.dart';

class ReportDetailRepository {
  final ReportDetailProvider _provider = ReportDetailProvider();

  // Fetch all report details for a report ID
  Future<List<ReportDetail>> fetchReportDetails(int reportId) async {
    return await _provider.getReportDetails(reportId);
  }

  // Add a new report detail
  Future<void> addReportDetail(
      int reportId, Map<String, dynamic> fields) async {
    await _provider.addReportDetail(reportId, fields);
  }

  // Update an existing report detail
  Future<void> updateReportDetail(
      int reportId, int detailId, Map<String, dynamic> fields) async {
    await _provider.updateReportDetail(reportId, detailId, fields);
  }

  // Delete a report detail
  Future<void> removeReportDetail(int reportId, int detailId) async {
    await _provider.deleteReportDetail(reportId, detailId);
  }
}
