class SocialAccount {
  final String? id;
  final String? platform;
  final String? username;
  final String? link;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SocialAccount({
    this.id,
    this.platform,
    this.username,
    this.link,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      id: json['id'] as String?,
      platform: json['platform'] as String?,
      username: json['username'] as String?,
      link: json['link'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'username': username,
      'link': link,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 