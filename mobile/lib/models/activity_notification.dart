class ActivityNotification {
  final String id;
  final String userId;
  final String message;
  final String type;
  final String? entityId;
  final bool isRead;
  final DateTime createdAt;

  ActivityNotification({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    this.entityId,
    required this.isRead,
    required this.createdAt,
  });

  factory ActivityNotification.fromJson(Map<String, dynamic> json) {
    return ActivityNotification(
      id: json['id'],
      userId: json['user_id'],
      message: json['message'],
      type: json['type'],
      entityId: json['entity_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'type': type,
      'entity_id': entityId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 