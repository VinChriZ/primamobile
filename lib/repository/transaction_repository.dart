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
  Future<void> addTransaction(Transaction transaction) async {
    await _provider.createTransaction(transaction);
  }

  // Update an existing transaction
  Future<void> editTransaction(
      int transactionId, Transaction transaction) async {
    await _provider.updateTransaction(transactionId, transaction);
  }

  // Delete a transaction
  Future<void> removeTransaction(int transactionId) async {
    await _provider.deleteTransaction(transactionId);
  }
}
