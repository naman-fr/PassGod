class BreachAlert {
  final String id;
  final String userId;
  final String platform;
  final String description;
  final String severity;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime breachDate;

  BreachAlert({
    required this.id,
    required this.userId,
    required this.platform,
    required this.description,
    required this.severity,
    required this.isResolved,
    required this.createdAt,
    required this.breachDate,
  });

  factory BreachAlert.fromJson(Map<String, dynamic> json) {
    return BreachAlert(
      id: json['id'],
      userId: json['user_id'],
      platform: json['platform'],
      description: json['description'],
      severity: json['severity'],
      isResolved: json['is_resolved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      breachDate: DateTime.parse(json['breach_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'platform': platform,
      'description': description,
      'severity': severity,
      'is_resolved': isResolved,
      'created_at': createdAt.toIso8601String(),
      'breach_date': breachDate.toIso8601String(),
    };
  }
} 