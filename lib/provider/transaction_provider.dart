import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class TransactionProvider {
  // Fetch all transactions
  Future<List<Transaction>> getTransactions() async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/transactions',
        queryParameters: await request.toJson(),
      );
      print('Get Transactions Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to fetch transactions with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }

  // Fetch a specific transaction by ID
  Future<Transaction> getTransaction(int transactionId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/transactions/$transactionId',
        queryParameters: await request.toJson(),
      );
      print('Get Transaction Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Transaction.fromJson(data);
      } else {
        throw Exception(
          'Failed to fetch transaction with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching transaction: $e');
      rethrow;
    }
  }

  // Create a new transaction
  Future<Transaction> createTransaction(Map<String, dynamic> fields) async {
    final RequestParam param = RequestParam(parameters: fields);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.post(
        '/transactions',
        data: await request.toJson(),
      );
      print('Create Transaction Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return Transaction.fromJson(data);
      } else {
        throw Exception(
          'Failed to create transaction with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  // Update an existing transaction
  Future<Transaction> updateTransaction(
      int transactionId, Map<String, dynamic> fields) async {
    final RequestParam param = RequestParam(parameters: fields);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.put(
        '/transactions/$transactionId',
        data: await request.toJson(),
      );
      print('Update Transaction Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Transaction.fromJson(data);
      } else {
        throw Exception(
          'Failed to update transaction with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(int transactionId) async {
    final RequestParam param = RequestParam(parameters: {});
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.delete(
        '/transactions/$transactionId',
        data: await request.toJson(),
      );
      print('Delete Transaction Response: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete transaction with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }
}
