import 'package:primamobile/app/models/transaction/transaction_detail.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class TransactionDetailProvider {
  // Fetch all transaction details for a given transaction ID
  Future<List<TransactionDetail>> getTransactionDetails(
      int transactionId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/transactions/$transactionId/details',
        queryParameters: await request.toJson(),
      );
      print('Transaction Details Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => TransactionDetail.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to fetch transaction details with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
      rethrow;
    }
  }

  // Add a new transaction detail
  Future<void> addTransactionDetail(
      int transactionId, Map<String, dynamic> fields) async {
    final RequestParam param = RequestParam(parameters: fields);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.post(
        '/transactions/$transactionId/details',
        data: await request.toJson(),
      );
      print('Add Transaction Detail Response: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to add transaction detail with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error adding transaction detail: $e');
      rethrow;
    }
  }

  // Update an existing transaction detail
  Future<void> updateTransactionDetail(
      int transactionId, int detailId, Map<String, dynamic> fields) async {
    final RequestParam param = RequestParam(parameters: fields);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.put(
        '/transactions/$transactionId/details/$detailId',
        data: await request.toJson(),
      );
      print('Update Transaction Detail Response: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update transaction detail with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error updating transaction detail: $e');
      rethrow;
    }
  }

  // Delete a transaction detail
  Future<void> deleteTransactionDetail(int transactionId, int detailId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.delete(
        '/transactions/$transactionId/details/$detailId',
        data: await request.toJson(),
      );
      print('Delete Transaction Detail Response: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete transaction detail with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error deleting transaction detail: $e');
      rethrow;
    }
  }
}
