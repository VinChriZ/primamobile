class Report {
  final int reportId;
  final int userId;
  final DateTime dateCreated;
  final DateTime lastUpdated;
  final String type; // Expected values: 'restock' or 'return'
  final String
      status; // Expected values: 'approved', 'disapproved', or 'waiting'

  Report({
    required this.reportId,
    required this.userId,
    required this.dateCreated,
    required this.lastUpdated,
    required this.type,
    required this.status,
  });

  // Creates a Report instance from a JSON map
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['report_id'] as int,
      userId: json['user_id'] as int,
      dateCreated: DateTime.parse(json['date_created'] as String),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      type: json['type'] as String,
      status: json['status'] as String,
    );
  }

  // Converts the Report instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date_created': dateCreated.toIso8601String(),
      'type': type,
      'status': status,
    };
  }
}
