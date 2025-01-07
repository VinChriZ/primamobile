import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/dio/dio_client.dart';

class TransactionProvider {
  // Fetch all transactions
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await dioClient.get('/transactions');
      print('Get Transactions Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch transactions with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }

  // Fetch a specific transaction by ID
  Future<Transaction> getTransaction(int transactionId) async {
    try {
      final response = await dioClient.get('/transactions/$transactionId');
      print('Get Transaction Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Transaction.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch transaction with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching transaction: $e');
      rethrow;
    }
  }

  // Create a new transaction
  Future<void> createTransaction(Transaction transaction) async {
    try {
      final response = await dioClient.post(
        '/transactions',
        data: transaction.toJson(),
      );
      print('Create Transaction Response: ${response.data}');
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  // Update an existing transaction
  Future<void> updateTransaction(
      int transactionId, Transaction transaction) async {
    try {
      final response = await dioClient.put(
        '/transactions/$transactionId',
        data: transaction.toJson(),
      );
      print('Update Transaction Response: ${response.data}');
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(int transactionId) async {
    try {
      final response = await dioClient.delete('/transactions/$transactionId');
      print('Delete Transaction Response: ${response.data}');
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }
}
