class Transaction {
  final int transactionId;
  final double totalDisplayPrice;
  final DateTime dateCreated;
  final String? note; // Note is now optional
  final DateTime lastUpdated;

  Transaction({
    required this.transactionId,
    required this.totalDisplayPrice,
    required this.dateCreated,
    this.note, // Optional field
    required this.lastUpdated,
  });

  // Create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['TransactionID'],
      totalDisplayPrice: json['TotalDisplayPrice'],
      dateCreated: DateTime.parse(json['DateCreated']),
      note: json['Note'], // This can be null if not provided
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  // Convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'TransactionID': transactionId,
      'TotalDisplayPrice': totalDisplayPrice,
      'DateCreated': dateCreated.toIso8601String(),
      if (note != null) 'Note': note, // Only include if not null
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
