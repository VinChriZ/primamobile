class Transaction {
  final int transactionId;
  final double totalDisplayPrice;
  final String date;
  final String note;

  Transaction({
    required this.transactionId,
    required this.totalDisplayPrice,
    required this.date,
    required this.note,
  });

  // Create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['TransactionID'],
      totalDisplayPrice: json['TotalDisplayPrice'],
      date: json['Date'],
      note: json['Note'],
    );
  }

  // Convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'TransactionID': transactionId,
      'TotalDisplayPrice': totalDisplayPrice,
      'Date': date,
      'Note': note,
    };
  }
}
