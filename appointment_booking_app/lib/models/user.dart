class User {
  final int userId;
  final String? googleId;
  final String name;
  final String email;
  final String role;

  User({
    required this.userId,
    this.googleId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('User.fromJson: $json');
    try {
      return User(
        userId: int.parse(json['user_id'].toString()),
        googleId: json['google_id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
      );
    } catch (e) {
      print('User.fromJson error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'google_id': googleId,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}