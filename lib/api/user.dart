class UserModel {
  final String id;
  final String username;
  final String role;
  final String email;
  final String? avatar;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.email,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'email': email,
      'avatar': avatar,
    };
  }
}
