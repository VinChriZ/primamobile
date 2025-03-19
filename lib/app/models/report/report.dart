class Report {
  final int reportId;
  final int userId;
  final DateTime dateCreated;
  final DateTime lastUpdated;
  final String type;
  final String status;
  final String? note; // Added optional note field

  Report({
    required this.reportId,
    required this.userId,
    required this.dateCreated,
    required this.lastUpdated,
    required this.type,
    required this.status,
    this.note, // Optional
  });

  // Creates a Report instance from a JSON map
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['report_id'] as int,
      userId: json['user_id'] as int,
      dateCreated: DateTime.parse(json['date_created']),
      lastUpdated: DateTime.parse(json['last_updated']),
      type: json['type'] as String,
      status: json['status'] as String,
      note: json['note'] as String?, // Parse optional note field
    );
  }

  // Converts the Report instance into a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'date_created': dateCreated.toIso8601String(),
      'type': type,
      'status': status,
    };

    if (note != null) {
      data['note'] = note;
    }

    return data;
  }
}
