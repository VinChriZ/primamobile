import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class ReportProvider {
  // Fetch all reports with optional filtering by status and type
  Future<List<Report>> getReports({String? status, String? reportType}) async {
    final Map<String, dynamic> queryParameters = {};
    if (status != null) {
      queryParameters['status'] = status;
    }
    if (reportType != null) {
      queryParameters['report_type'] = reportType;
    }
    final RequestParam param = RequestParam(parameters: queryParameters);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/reports/',
        queryParameters: await request.toJson(),
      );
      print('Get Reports Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => Report.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch reports with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reports: $e');
      rethrow;
    }
  }

  // Fetch a specific report by ID
  Future<Report> getReport(int reportId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/reports/$reportId',
        queryParameters: await request.toJson(),
      );
      print('Get Report Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Report.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch report with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching report: $e');
      rethrow;
    }
  }

  // Create a new report
  Future<Report> createReport(Map<String, dynamic> fields) async {
    final RequestParam param = RequestParam(parameters: fields);
    final RequestObject request = RequestObjectFunction(requestParam: param);
    final payload = await request.toJson();
    print('Create Report Payload: $payload');

    try {
      final response = await dioClient.post(
        '/reports/',
        data: payload,
      );
      print('Create Report Response: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return Report.fromJson(data);
      } else {
        throw Exception(
            'Failed to create report with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating report: $e');
      rethrow;
    }
  }

  // Update an existing report
  Future<Report> updateReport(int reportId, Map<String, dynamic> fields) async {
    final RequestParam param = RequestParam(parameters: fields);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.put(
        '/reports/$reportId',
        data: await request.toJson(),
      );
      print('Update Report Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Report.fromJson(data);
      } else {
        throw Exception(
            'Failed to update report with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating report: $e');
      rethrow;
    }
  }

  // Delete a report
  Future<void> deleteReport(int reportId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.delete(
        '/reports/$reportId',
        data: await request.toJson(),
      );
      print('Delete Report Response: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete report with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }
}
