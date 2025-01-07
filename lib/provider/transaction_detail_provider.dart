import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/dio/dio_client.dart';

class TransactionDetailProvider {
  // Fetch all transaction details for a given transaction ID
  Future<List<TransactionDetail>> getTransactionDetails(
      int transactionId) async {
    try {
      final response =
          await dioClient.get('/transactions/$transactionId/details');
      print('Transaction Details Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => TransactionDetail.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch transaction details with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
      rethrow;
    }
  }

  // Add a new transaction detail
  Future<void> addTransactionDetail(
      int transactionId, TransactionDetail detail) async {
    try {
      final response = await dioClient.post(
        '/transactions/$transactionId/details',
        data: detail.toJson(),
      );
      print('Add Transaction Detail Response: ${response.data}');
    } catch (e) {
      print('Error adding transaction detail: $e');
      rethrow;
    }
  }

  // Update an existing transaction detail
  Future<void> updateTransactionDetail(
      int transactionId, int detailId, TransactionDetail detail) async {
    try {
      final response = await dioClient.put(
        '/transactions/$transactionId/details/$detailId',
        data: detail.toJson(),
      );
      print('Update Transaction Detail Response: ${response.data}');
    } catch (e) {
      print('Error updating transaction detail: $e');
      rethrow;
    }
  }

  // Delete a transaction detail
  Future<void> deleteTransactionDetail(int transactionId, int detailId) async {
    try {
      final response = await dioClient.delete(
        '/transactions/$transactionId/details/$detailId',
      );
      print('Delete Transaction Detail Response: ${response.data}');
    } catch (e) {
      print('Error deleting transaction detail: $e');
      rethrow;
    }
  }
}
