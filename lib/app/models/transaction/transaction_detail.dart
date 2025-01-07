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
      detailId: json['DetailID'],
      transactionId: json['TransactionID'],
      upc: json['UPC'],
      quantity: json['Quantity'],
      agreedPrice: json['AgreedPrice'],
    );
  }

  // Convert TransactionDetail to JSON
  Map<String, dynamic> toJson() {
    return {
      'DetailID': detailId,
      'TransactionID': transactionId,
      'UPC': upc,
      'Quantity': quantity,
      'AgreedPrice': agreedPrice,
    };
  }
}
