class Transaction {
  final int transactionId;
  final double totalDisplayPrice;
  final double totalAgreedPrice; // Added this field based on your table
  final DateTime dateCreated;
  final String? note; // Note is optional
  final DateTime lastUpdated;

  Transaction({
    required this.transactionId,
    required this.totalDisplayPrice,
    required this.totalAgreedPrice, // New field
    required this.dateCreated,
    this.note, // Optional field
    required this.lastUpdated,
  });

  // Create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'], // Matches your database field
      totalDisplayPrice: (json['total_display_price'] as num).toDouble(),
      totalAgreedPrice: (json['total_agreed_price'] as num).toDouble(),
      dateCreated: DateTime.parse(json['date_created']),
      note: json['note'], // Can be null
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  // Convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'total_display_price': totalDisplayPrice,
      'total_agreed_price': totalAgreedPrice, // Include in serialization
      'date_created': dateCreated.toIso8601String(),
      if (note != null) 'note': note, // Only include if not null
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
