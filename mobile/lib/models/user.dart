class User {
  final String id;
  final String email;
  final String fullName;
  final bool? isActive;
  final bool? isVerified;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.isActive = false,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['full_name'],
      isActive: json['is_active'] ?? false,
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
      'is_verified': isVerified,
    };
  }
} 