class PrivateItem {
  final String? id;
  final String itemType;
  final String encryptedData;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrivateItem({
    this.id,
    required this.itemType,
    required this.encryptedData,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrivateItem.fromJson(Map<String, dynamic> json) {
    return PrivateItem(
      id: json['id'],
      itemType: json['item_type'],
      encryptedData: json['encrypted_data'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_type': itemType,
      'encrypted_data': encryptedData,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 