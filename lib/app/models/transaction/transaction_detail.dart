class TransactionDetail {
  final int detailId;
  final int transactionId;
  final String upc;
  final int quantity;
  final double agreedPrice;

  TransactionDetail({
    required this.detailId,
    required this.transactionId,
    required this.upc,
    required this.quantity,
    required this.agreedPrice,
  });

  // Create TransactionDetail from JSON
  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      detailId: json['detail_id'], // Matches database field
      transactionId: json['transaction_id'], // Matches database field
      upc: json['upc'], // Matches database field
      quantity: json['quantity'], // Matches database field
      agreedPrice:
          (json['agreed_price'] as num).toDouble(), // Matches database field
    );
  }

  // Convert TransactionDetail to JSON
  Map<String, dynamic> toJson() {
    return {
      'detail_id': detailId, // Matches database field
      'transaction_id': transactionId, // Matches database field
      'upc': upc, // Matches database field
      'quantity': quantity, // Matches database field
      'agreed_price': agreedPrice, // Matches database field
    };
  }
}
