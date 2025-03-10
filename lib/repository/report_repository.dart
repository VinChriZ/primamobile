import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/provider/report_provider.dart';

class ReportRepository {
  final ReportProvider _provider = ReportProvider();

  // Fetch all reports with optional filters
  Future<List<Report>> fetchReports(
      {String? status, String? reportType}) async {
    return await _provider.getReports(status: status, reportType: reportType);
  }

  // Fetch a specific report by ID
  Future<Report> fetchReport(int reportId) async {
    return await _provider.getReport(reportId);
  }

  // Create a new report
  Future<Report> addReport(Map<String, dynamic> fields) async {
    return await _provider.createReport(fields);
  }

  // Update an existing report
  Future<Report> editReport(int reportId, Map<String, dynamic> fields) async {
    return await _provider.updateReport(reportId, fields);
  }

  // Delete a report
  Future<void> removeReport(int reportId) async {
    await _provider.deleteReport(reportId);
  }
}
