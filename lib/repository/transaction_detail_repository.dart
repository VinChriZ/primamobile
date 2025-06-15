import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/transaction_detail_provider.dart';

class TransactionDetailRepository {
  final TransactionDetailProvider _provider = TransactionDetailProvider();

  // Fetch all transaction details for a transaction ID
  Future<List<TransactionDetail>> fetchTransactionDetails(
      int transactionId) async {
    return await _provider.getTransactionDetails(transactionId);
  }

  // Add a new transaction detail
  Future<void> addTransactionDetail(
      int transactionId, Map<String, dynamic> fields) async {
    await _provider.addTransactionDetail(transactionId, fields);
  }

  // Update an existing transaction detail
  Future<void> updateTransactionDetail(
      int transactionId, int detailId, Map<String, dynamic> fields) async {
    await _provider.updateTransactionDetail(transactionId, detailId, fields);
  }

  // Delete a transaction detail
  Future<void> removeTransactionDetail(int transactionId, int detailId) async {
    await _provider.deleteTransactionDetail(transactionId, detailId);
  }

  // Check if a UPC exists in any transaction detail
  Future<bool> checkUpcExists(String upc) async {
    return await _provider.checkUpcExists(upc);
  }
}
