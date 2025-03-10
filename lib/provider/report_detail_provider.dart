import 'package:primamobile/app/models/report/report_detail.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class ReportDetailProvider {
  // Fetch all report details for a given report ID
  Future<List<ReportDetail>> getReportDetails(int reportId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/reports/$reportId/details',
        queryParameters: await request.toJson(),
      );
      print('Report Details Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => ReportDetail.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch report details with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching report details: $e');
      rethrow;
    }
  }

  // Add a new report detail
  Future<void> addReportDetail(
      int reportId, Map<String, dynamic> fields) async {
    final RequestParam param = RequestParam(parameters: fields);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.post(
        '/reports/$reportId/details',
        data: await request.toJson(),
      );
      print('Add Report Detail Response: ${response.data}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to add report detail with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding report detail: $e');
      rethrow;
    }
  }

  // Update an existing report detail
  Future<void> updateReportDetail(
      int reportId, int detailId, Map<String, dynamic> fields) async {
    final RequestParam param = RequestParam(parameters: fields);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.put(
        '/reports/$reportId/details/$detailId',
        data: await request.toJson(),
      );
      print('Update Report Detail Response: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update report detail with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating report detail: $e');
      rethrow;
    }
  }

  // Delete a report detail
  Future<void> deleteReportDetail(int reportId, int detailId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.delete(
        '/reports/$reportId/details/$detailId',
        data: await request.toJson(),
      );
      print('Delete Report Detail Response: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete report detail with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting report detail: $e');
      rethrow;
    }
  }
}
