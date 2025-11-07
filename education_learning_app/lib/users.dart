class User {
  final String userId;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;

  // Constructor
  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  // fromJson - Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // toJson - Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // toString - String representation of User object
  @override
  String toString() {
    return 'User{userId: $userId, name: $name, email: $email, password: $password, createdAt: $createdAt}';
  }
}