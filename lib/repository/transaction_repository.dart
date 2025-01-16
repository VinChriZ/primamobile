import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/transaction_provider.dart';

class TransactionRepository {
  final TransactionProvider _provider = TransactionProvider();

  // Fetch all transactions
  Future<List<Transaction>> fetchTransactions() async {
    return await _provider.getTransactions();
  }

  // Fetch a specific transaction by ID
  Future<Transaction> fetchTransaction(int transactionId) async {
    return await _provider.getTransaction(transactionId);
  }

  // Create a new transaction
  Future<Transaction> addTransaction(Map<String, dynamic> fields) async {
    return await _provider.createTransaction(fields);
  }

  // Update an existing transaction
  Future<Transaction> editTransaction(
      int transactionId, Map<String, dynamic> fields) async {
    return await _provider.updateTransaction(transactionId, fields);
  }

  // Delete a transaction
  Future<void> removeTransaction(int transactionId) async {
    await _provider.deleteTransaction(transactionId);
  }
}
