class Users {
  final String userId;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;
  final String role; // e.g., 'Student', 'Teacher'

  Users({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.role,
  });

  // Factory constructor to create a User from a JSON Map
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: json['role'] as String,
    );
  }

  // Method to convert a User object to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'role': role,
    };
  }

  // Method to provide a string representation of the object
  @override
  String toString() {
    return 'User(userId: $userId, name: $name, email: $email, role: $role, createdAt: $createdAt)';
  }
}