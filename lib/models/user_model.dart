class UserModel {
  final String id;
  final String name;
  final String email;
  final String? token;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.createdAt,
  });

  // Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  // Convert UserModel to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (token != null) 'token': token,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  // Helper method to create a copy of UserModel with some updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
