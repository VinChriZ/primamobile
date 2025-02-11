class Transaction {
  final int transactionId;
  final double totalDisplayPrice;
  final double totalAgreedPrice; // Calculated field (managed by trigger)
  final DateTime dateCreated;
  final String? note; // Optional field
  final DateTime lastUpdated;

  Transaction({
    required this.transactionId,
    required this.totalDisplayPrice,
    required this.totalAgreedPrice, // New field
    required this.dateCreated,
    this.note, // Optional field
    required this.lastUpdated,
  });

  // Create a Transaction object from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'], // Matches database field
      totalDisplayPrice: (json['total_display_price'] as num).toDouble(),
      totalAgreedPrice: (json['total_agreed_price'] as num).toDouble(),
      dateCreated: DateTime.parse(json['date_created']),
      note: json['note'], // Can be null
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  // Convert a Transaction object to JSON
  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'date_created': dateCreated.toIso8601String(),
      if (note != null) 'note': note, // Include only if not null
    };
  }
}
