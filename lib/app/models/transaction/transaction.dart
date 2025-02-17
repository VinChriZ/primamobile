class Transaction {
  final int transactionId;
  final double totalDisplayPrice;
  final double totalAgreedPrice;
  final double totalNetPrice;
  final int quantity;
  final DateTime dateCreated;
  final String? note;
  final DateTime lastUpdated;

  Transaction({
    required this.transactionId,
    required this.totalDisplayPrice,
    required this.totalAgreedPrice,
    required this.totalNetPrice,
    required this.quantity,
    required this.dateCreated,
    this.note,
    required this.lastUpdated,
  });

  // Create a Transaction object from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'],
      totalDisplayPrice: (json['total_display_price'] as num).toDouble(),
      totalAgreedPrice: (json['total_agreed_price'] as num).toDouble(),
      totalNetPrice: (json['total_net_price'] as num).toDouble(),
      quantity: json['quantity'],
      dateCreated: DateTime.parse(json['date_created']),
      note: json['note'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  // Convert a Transaction object to JSON
  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'date_created': dateCreated.toUtc().toIso8601String(),
      if (note != null) 'note': note,
    };
  }
}
