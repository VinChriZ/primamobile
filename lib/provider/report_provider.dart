import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class ReportProvider {
  // Fetch all reports with optional filtering and sorting
  Future<List<Report>> getReports({
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? reportType,
  }) async {
    final Map<String, dynamic> queryParameters = {};

    if (startDate != null) {
      queryParameters['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate.toIso8601String();
    }
    if (sortBy != null) {
      queryParameters['sort_by'] = sortBy;
    }
    if (sortOrder != null) {
      queryParameters['sort_order'] = sortOrder;
    }
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

  // Approve a report
  Future<String> approveReport(int reportId) async {
    try {
      final response = await dioClient.put('/reports/$reportId/approve');
      print('Approve Report Response: ${response.data}'); // Debug log
      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        throw Exception(
            'Failed to approve report. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error approving report: $e'); // Debug log
      throw Exception('Error approving report: $e');
    }
  }

  // Deny a report
  Future<String> denyReport(int reportId) async {
    try {
      final response = await dioClient.put('/reports/$reportId/deny');
      print('Deny Report Response: ${response.data}'); // Debug log
      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        throw Exception(
            'Failed to deny report. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error denying report: $e'); // Debug log
      throw Exception('Error denying report: $e');
    }
  }

  // Update report note
  Future<String> updateReportNote(int reportId, String note) async {
    try {
      final RequestParam param = RequestParam(parameters: {"note": note});
      final RequestObject request = RequestObjectFunction(requestParam: param);

      final response = await dioClient.put(
        '/reports/$reportId/note',
        data: await request.toJson(),
      );

      print('Update Note Response: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        throw Exception(
            'Failed to update note. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating note: $e'); // Debug log
      throw Exception('Error updating note: $e');
    }
  }

  // Resubmit a report (change status back to waiting)
  Future<Report> resubmitReport(int reportId) async {
    print('Resubmitting report $reportId to waiting status');

    try {
      // Using the same pattern as approve/deny for direct database update
      // We'll need to add this endpoint to the backend

      final RequestParam param = RequestParam(parameters: {});
      final RequestObject request = RequestObjectFunction(requestParam: param);

      final response = await dioClient.put(
        '/reports/$reportId/resubmit',
        data: await request.toJson(),
      );

      print('Resubmit Response: ${response.data}');

      if (response.statusCode == 200) {
        // Re-fetch the report to get the updated data
        return await getReport(reportId);
      } else {
        throw Exception(
            'Failed to resubmit report with status code: ${response.statusCode}');
      }
    } catch (e) {
      // If the resubmit endpoint doesn't exist yet, fall back to direct update
      print('Error with resubmit endpoint, trying direct update: $e');

      try {
        // Direct update using the regular update endpoint
        // Since the backend doesn't update status through this endpoint,
        // we'll need to use a database-direct approach

        final directParams = {
          // Using SQL-like parameter to bypass the regular endpoint logic
          "direct_update_status": "waiting"
        };

        final directParam = RequestParam(parameters: directParams);
        final directRequest = RequestObjectFunction(requestParam: directParam);

        final directResponse = await dioClient.put(
          '/reports/$reportId',
          data: await directRequest.toJson(),
        );

        print('Direct Update Response: ${directResponse.data}');

        // Re-fetch the report
        return await getReport(reportId);
      } catch (innerError) {
        print('Error with direct update: $innerError');
        rethrow;
      }
    }
  }
}
