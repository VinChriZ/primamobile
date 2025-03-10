class ReportDetail {
  final int reportDetailId;
  final int reportId;
  final String upc;
  final int quantity;

  ReportDetail({
    required this.reportDetailId,
    required this.reportId,
    required this.upc,
    required this.quantity,
  });

  // Creates a ReportDetail instance from a JSON map
  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      reportDetailId: json['report_detail_id'] as int,
      reportId: json['report_id'] as int,
      upc: json['upc'] as String,
      quantity: json['quantity'] as int,
    );
  }

  // Converts the ReportDetail instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'upc': upc,
      'quantity': quantity,
    };
  }
}
